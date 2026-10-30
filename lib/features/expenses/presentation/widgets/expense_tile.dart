import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/expense.dart';

/// One row in the expense list or dashboard.
class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense, required this.currency});

  final Expense expense;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            ),
            child: Icon(
              categoryIconFor(expense.category.icon),
              size: 22,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.category.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  expense.note.isEmpty
                      ? formatExpenseDate(expense.date)
                      : '${expense.note} · ${formatExpenseDate(expense.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '− ${formatCents(expense.amountCents, currency)}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.pennyColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}
