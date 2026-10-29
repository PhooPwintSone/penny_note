import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/income_category.dart';
import '../providers/income_category_providers.dart';
import 'income_category_form_screen.dart';

class IncomeCategoriesScreen extends ConsumerWidget {
  const IncomeCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(incomeCategoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Income categories')),
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load income categories',
              message: error.toString(),
              action: TextButton(
                onPressed: () => ref.invalidate(incomeCategoriesStreamProvider),
                child: const Text('Try again'),
              ),
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: EmptyState(
                  icon: Icons.category_outlined,
                  title: 'No income categories yet',
                  message: 'Add a category to start recording income.',
                  action: TextButton.icon(
                    onPressed: () => _openForm(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add category'),
                  ),
                ),
              ),
            );
          }

          return ResponsiveContent(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                120,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final category = items[index];
                return AppCard(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.xs,
                    top: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.tileRadius,
                          ),
                        ),
                        child: Icon(
                          categoryIconFor(category.icon),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          category.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      PopupMenuButton<_IncomeCategoryAction>(
                        tooltip: 'Income category options',
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onSelected: (action) {
                          switch (action) {
                            case _IncomeCategoryAction.edit:
                              _openForm(context, category);
                            case _IncomeCategoryAction.delete:
                              _confirmAndDelete(context, ref, category);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _IncomeCategoryAction.edit,
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: AppSpacing.sm),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: _IncomeCategoryAction.delete,
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 20),
                                SizedBox(width: AppSpacing.sm),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        tooltip: 'Add income category',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _openForm(BuildContext context, [IncomeCategory? category]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => IncomeCategoryFormScreen(category: category),
      ),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    IncomeCategory category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete income category?'),
        content: Text(
          'Delete “${category.name}”? Categories used by income entries cannot '
          'be deleted until those entries are moved or removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(deleteIncomeCategoryUseCaseProvider)(category.id);
    } on AppFailure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }
  }
}

enum _IncomeCategoryAction { edit, delete }
