import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/income.dart';
import '../viewmodels/incomes_view_model.dart';
import '../widgets/income_tile.dart';
import 'add_income_screen.dart';

class IncomesScreen extends ConsumerWidget {
  const IncomesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomesState = ref.watch(incomesViewModelProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
        actions: [
          incomesState.maybeWhen(
            data: (state) => state.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(
                      right: AppSpacing.screenPadding,
                    ),
                    child: Center(
                      child: Text(
                        '${state.incomes.length} '
                        '${state.incomes.length == 1 ? 'entry' : 'entries'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: incomesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load your income',
              message: error.toString(),
              action: TextButton(
                onPressed: () => ref.invalidate(incomesViewModelProvider),
                child: const Text('Try again'),
              ),
            ),
          ),
        ),
        data: (state) {
          if (state.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: EmptyState(
                  icon: Icons.payments_outlined,
                  title: 'No income recorded yet',
                  message:
                      'Every income entry you add will be listed here, '
                      'newest first.',
                  action: TextButton.icon(
                    onPressed: () => _openAddIncome(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add income'),
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
              itemCount: state.incomes.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final income = state.incomes[index];

                return AppCard(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.xs,
                    top: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: IncomeTile(income: income, currency: currency),
                      ),
                      PopupMenuButton<_IncomeAction>(
                        tooltip: 'Income options',
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onSelected: (action) {
                          switch (action) {
                            case _IncomeAction.edit:
                              _openIncomeForm(context, income);
                            case _IncomeAction.delete:
                              _confirmAndDelete(context, ref, income.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: _IncomeAction.edit,
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: AppSpacing.sm),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: _IncomeAction.delete,
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
        // All AppShell tabs stay mounted in an IndexedStack, so this FAB
        // cannot share the default Hero tag with the other tab FABs.
        heroTag: null,
        onPressed: () => _openAddIncome(context),
        tooltip: 'Add income',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _openAddIncome(BuildContext context) {
    _openIncomeForm(context, null);
  }

  void _openIncomeForm(BuildContext context, Income? income) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AddIncomeScreen(income: income)),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    int incomeId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete income entry?'),
        content: const Text('This entry will be removed from your journal.'),
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
      await ref.read(incomesViewModelProvider.notifier).deleteIncome(incomeId);
    } on AppFailure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }
  }
}

enum _IncomeAction { edit, delete }
