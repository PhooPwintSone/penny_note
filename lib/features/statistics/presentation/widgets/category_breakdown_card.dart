import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/statistics.dart';

/// A ranked list of categories with amounts and proportional bars.
class CategoryBreakdownCard extends StatelessWidget {
  const CategoryBreakdownCard({
    super.key,
    required this.categories,
    required this.totalCents,
    required this.currency,
    required this.color,
    required this.totalLabel,
    required this.emptyMessage,
  });

  final List<CategoryTotal> categories;
  final int totalCents;
  final AppCurrency currency;
  final Color color;
  final String totalLabel;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      final theme = Theme.of(context);

      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.category_outlined, color: color.withValues(alpha: 0.75)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                emptyMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: [
          for (var index = 0; index < categories.length; index++) ...[
            if (index > 0) const Divider(),
            _CategoryRow(
              category: categories[index],
              totalCents: totalCents,
              currency: currency,
              color: color,
              totalLabel: totalLabel,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.totalCents,
    required this.currency,
    required this.color,
    required this.totalLabel,
  });

  final CategoryTotal category;
  final int totalCents;
  final AppCurrency currency;
  final Color color;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final fraction = totalCents <= 0
        ? 0.0
        : (category.amountCents / totalCents).clamp(0.0, 1.0).toDouble();
    final percent = (fraction * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(categoryIconFor(category.icon), size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatCents(category.amountCents, currency),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$percent% of $totalLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
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
