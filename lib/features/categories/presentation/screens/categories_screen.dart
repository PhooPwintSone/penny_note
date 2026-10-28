import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';
import 'category_form_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load categories',
              message: error.toString(),
              action: TextButton(
                onPressed: () => ref.invalidate(categoriesStreamProvider),
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
                  title: 'No categories yet',
                  message: 'Add a category to start recording expenses.',
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
                      PopupMenuButton<_CategoryAction>(
                        tooltip: 'Category options',
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onSelected: (action) {
                          switch (action) {
                            case _CategoryAction.edit:
                              _openForm(context, category);
                            case _CategoryAction.delete:
                              _confirmAndDelete(context, ref, category);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _CategoryAction.edit,
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: AppSpacing.sm),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: _CategoryAction.delete,
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
        tooltip: 'Add category',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _openForm(BuildContext context, [Category? category]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryFormScreen(category: category),
      ),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Delete “${category.name}”? Categories used by expenses cannot be '
          'deleted until those expenses are moved or removed.',
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
      await ref.read(deleteCategoryUseCaseProvider)(category.id);
    } on AppFailure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }
  }
}

enum _CategoryAction { edit, delete }
