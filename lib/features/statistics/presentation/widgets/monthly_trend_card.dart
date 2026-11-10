import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/statistics.dart';

/// A compact income-versus-expense bar chart for the last few months.
class MonthlyTrendCard extends StatelessWidget {
  const MonthlyTrendCard({
    super.key,
    required this.points,
    required this.currency,
  });

  final List<MonthlyTotal> points;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final incomeColor = context.pennyColors.income;
    final expenseColor = context.pennyColors.expense;
    final maxCents = points.fold<int>(
      1,
      (max, point) =>
          math.max(max, math.max(point.incomeCents, point.expenseCents)),
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _LegendDot(color: incomeColor, label: 'Income'),
              const SizedBox(width: AppSpacing.lg),
              _LegendDot(color: expenseColor, label: 'Expenses'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < points.length; index++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : AppSpacing.xs,
                        right: index == points.length - 1 ? 0 : AppSpacing.xs,
                      ),
                      child: _TrendColumn(
                        point: points[index],
                        maxCents: maxCents,
                        currency: currency,
                        incomeColor: incomeColor,
                        expenseColor: expenseColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TrendColumn extends StatelessWidget {
  const _TrendColumn({
    required this.point,
    required this.maxCents,
    required this.currency,
    required this.incomeColor,
    required this.expenseColor,
  });

  final MonthlyTotal point;
  final int maxCents;
  final AppCurrency currency;
  final Color incomeColor;
  final Color expenseColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxBarHeight = constraints.maxHeight;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TrendBar(
                    height: maxBarHeight * (point.incomeCents / maxCents),
                    color: incomeColor,
                    tooltip:
                        '${formatMonthYear(point.month)} income: '
                        '${formatCents(point.incomeCents, currency)}',
                  ),
                  const SizedBox(width: 4),
                  _TrendBar(
                    height: maxBarHeight * (point.expenseCents / maxCents),
                    color: expenseColor,
                    tooltip:
                        '${formatMonthYear(point.month)} expenses: '
                        '${formatCents(point.expenseCents, currency)}',
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          formatShortMonth(point.month),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TrendBar extends StatelessWidget {
  const _TrendBar({
    required this.height,
    required this.color,
    required this.tooltip,
  });

  final double height;
  final Color color;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 8,
        height: math.max(3.0, height),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
    );
  }
}
