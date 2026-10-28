import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/expense.dart';
import '../viewmodels/expenses_view_model.dart';
import '../widgets/expense_tile.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesState = ref.watch(expensesViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          expensesState.maybeWhen(
            data: (state) => state.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(
                      right: AppSpacing.screenPadding,
                    ),
                    child: Center(
                      child: Text(
                        '${state.expenses.length} '
                        '${state.expenses.length == 1 ? 'entry' : 'entries'}',
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
      body: expensesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load your expenses',
              message: error.toString(),
              action: TextButton(
                onPressed: () => ref.invalidate(expensesViewModelProvider),
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
                  icon: Icons.receipt_long_rounded,
                  title: 'Nothing recorded yet',
                  message:
                      'Every expense you add will be listed here, '
                      'newest first.',
                  action: TextButton.icon(
                    onPressed: () => _openAddExpense(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add an expense'),
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
              itemCount: state.expenses.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final expense = state.expenses[index];

                return AppCard(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.xs,
                    top: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: ExpenseTile(expense: expense)),
                      PopupMenuButton<_ExpenseAction>(
                        tooltip: 'Expense options',
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onSelected: (action) {
                          switch (action) {
                            case _ExpenseAction.edit:
                              _openExpenseForm(context, expense);
                            case _ExpenseAction.delete:
                              _confirmAndDelete(context, ref, expense.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: _ExpenseAction.edit,
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: AppSpacing.sm),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: _ExpenseAction.delete,
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
        onPressed: () => _openAddExpense(context),
        tooltip: 'Add expense',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _openAddExpense(BuildContext context) {
    _openExpenseForm(context, null);
  }

  void _openExpenseForm(BuildContext context, Expense? expense) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddExpenseScreen(expense: expense),
      ),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    int expenseId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete expense?'),
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
      await ref
          .read(expensesViewModelProvider.notifier)
          .deleteExpense(expenseId);
    } on AppFailure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }
  }
}

enum _ExpenseAction { edit, delete }
