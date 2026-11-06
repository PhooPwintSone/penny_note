import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../expenses/presentation/screens/add_expense_screen.dart';
import '../../../expenses/presentation/widgets/expense_tile.dart';
import '../../../savings/presentation/screens/savings_screen.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/balance_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final currency = ref.watch(currencyProvider);
    final now = DateTime.now();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: homeState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: EmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'Could not load your journal',
                message: error.toString(),
                action: TextButton(
                  onPressed: () => ref.invalidate(homeViewModelProvider),
                  child: const Text('Try again'),
                ),
              ),
            ),
          ),
          data: (state) => ResponsiveContent(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                120,
              ),
              children: [
                Text(
                  '${greetingFor(now)} 👋',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  formatHeaderDate(now),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 36,
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: colors.tertiary.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                BalanceCard(
                  balanceCents: state.balanceCents,
                  cashBalanceCents: state.cashBalanceCents,
                  savingsBalanceCents: state.savingsBalanceCents,
                  currency: currency,
                ),
                const SizedBox(height: AppSpacing.md),
                _IncomeExpenseCards(
                  incomeCents: state.totalIncomeCents,
                  expenseCents: state.totalExpenseCents,
                  currency: currency,
                ),
                const SizedBox(height: AppSpacing.md),
                _SavingsShortcut(
                  totalCents: state.savingsBalanceCents,
                  currency: currency,
                  onTap: () => _openSavings(context),
                ),
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(title: 'Recent Expenses'),
                if (!state.hasExpenses)
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.tertiary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.tertiary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            size: 24,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No expenses yet.',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Tap + to record your first penny. '
                                'Everything stays on this device.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    child: Column(
                      children: [
                        for (
                          var i = 0;
                          i < state.recentExpenses.length;
                          i++
                        ) ...[
                          if (i > 0) const Divider(),
                          ExpenseTile(
                            expense: state.recentExpenses[i],
                            currency: currency,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // All AppShell tabs stay mounted in an IndexedStack, so this FAB
        // cannot share the default Hero tag with the other tab FABs.
        heroTag: null,
        onPressed: () => _openAddExpense(context),
        tooltip: 'Add expense',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _openAddExpense(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AddExpenseScreen()));
  }

  void _openSavings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SavingsScreen()));
  }
}

class _IncomeExpenseCards extends StatelessWidget {
  const _IncomeExpenseCards({
    required this.incomeCents,
    required this.expenseCents,
    required this.currency,
  });

  final int incomeCents;
  final int expenseCents;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final income = _SummaryCard(
      label: 'Income',
      amountCents: incomeCents,
      icon: Icons.south_west_rounded,
      color: context.pennyColors.income,
      currency: currency,
    );
    final expense = _SummaryCard(
      label: 'Expense',
      amountCents: expenseCents,
      icon: Icons.north_east_rounded,
      color: context.pennyColors.expense,
      currency: currency,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300) {
          return Column(
            children: [
              income,
              const SizedBox(height: AppSpacing.md),
              expense,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: income),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: expense),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amountCents,
    required this.icon,
    required this.color,
    required this.currency,
  });

  final String label;
  final int amountCents;
  final IconData icon;
  final Color color;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                  border: Border.all(color: colors.outline, width: 1.5),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatCents(amountCents, currency),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsShortcut extends StatelessWidget {
  const _SavingsShortcut({
    required this.totalCents,
    required this.currency,
    required this.onTap,
  });

  final int totalCents;
  final AppCurrency currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.secondary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
              border: Border.all(color: colors.outline, width: 1.5),
            ),
            child: Icon(Icons.savings_outlined, color: colors.secondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Savings',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalCents == 0
                      ? 'Start setting money aside'
                      : 'Money set aside for later',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                formatCents(totalCents, currency),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}
