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
import '../../../settings/presentation/providers/settings_providers.dart';
import '../viewmodels/statistics_view_model.dart';
import '../widgets/category_breakdown_card.dart';
import '../widgets/monthly_trend_card.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsState = ref.watch(statisticsViewModelProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: statisticsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load your statistics',
              message: error.toString(),
              action: TextButton(
                onPressed: () => ref.invalidate(statisticsViewModelProvider),
                child: const Text('Try again'),
              ),
            ),
          ),
        ),
        data: (state) {
          final snapshot = state.snapshot;
          return ResponsiveContent(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                120,
              ),
              children: [
                _MonthSelector(
                  month: state.month,
                  canGoNext: state.canGoNext,
                  onPrevious: () => ref
                      .read(statisticsViewModelProvider.notifier)
                      .previousMonth(),
                  onNext: state.canGoNext
                      ? () => ref
                            .read(statisticsViewModelProvider.notifier)
                            .nextMonth()
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SummaryCards(
                  incomeCents: snapshot.incomeCents,
                  expenseCents: snapshot.expenseCents,
                  netCents: snapshot.netCents,
                  currency: currency,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (snapshot.trend.any((point) => point.hasActivity)) ...[
                  const SectionHeader(title: 'Monthly trend'),
                  MonthlyTrendCard(points: snapshot.trend, currency: currency),
                  const SizedBox(height: AppSpacing.xl),
                ],
                if (!snapshot.hasActivity)
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: EmptyState(
                      icon: Icons.insights_rounded,
                      title:
                          'No activity in ${formatMonthYear(snapshot.month)}',
                      message:
                          'Add an expense or income entry for this month to '
                          'see totals and category breakdowns.',
                    ),
                  )
                else ...[
                  const SectionHeader(title: 'Expense categories'),
                  CategoryBreakdownCard(
                    categories: snapshot.expenseCategories,
                    totalCents: snapshot.expenseCents,
                    currency: currency,
                    color: context.pennyColors.expense,
                    totalLabel: 'expenses',
                    emptyMessage: 'No expenses recorded for this month.',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'Income categories'),
                  CategoryBreakdownCard(
                    categories: snapshot.incomeCategories,
                    totalCents: snapshot.incomeCents,
                    currency: currency,
                    color: context.pennyColors.income,
                    totalLabel: 'income',
                    emptyMessage: 'No income recorded for this month.',
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.canGoNext,
    required this.onPrevious,
    this.onNext,
  });

  final DateTime month;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            tooltip: 'Previous month',
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  formatMonthYear(month),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  canGoNext ? 'Monthly overview' : 'This month',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNext,
            tooltip: 'Next month',
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.incomeCents,
    required this.expenseCents,
    required this.netCents,
    required this.currency,
  });

  final int incomeCents;
  final int expenseCents;
  final int netCents;
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
      label: 'Expenses',
      amountCents: expenseCents,
      icon: Icons.north_east_rounded,
      color: context.pennyColors.expense,
      currency: currency,
    );

    return Column(
      children: [
        LayoutBuilder(
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
        ),
        const SizedBox(height: AppSpacing.md),
        _NetCard(netCents: netCents, currency: currency),
      ],
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

class _NetCard extends StatelessWidget {
  const _NetCard({required this.netCents, required this.currency});

  final int netCents;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isNegative = netCents < 0;
    final color = netCents == 0
        ? colors.onSurfaceVariant
        : isNegative
        ? context.pennyColors.expense
        : context.pennyColors.income;
    final icon = netCents == 0
        ? Icons.trending_flat_rounded
        : isNegative
        ? Icons.trending_down_rounded
        : Icons.trending_up_rounded;
    final amount = formatCents(netCents.abs(), currency);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
              border: Border.all(color: colors.outline, width: 1.5),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net this month',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Income minus expenses',
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
                '${isNegative ? '− ' : ''}$amount',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
