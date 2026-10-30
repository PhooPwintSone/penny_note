import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money.dart';

/// The primary balance summary at the top of the dashboard.
///
/// Colors come from the theme's `primaryContainer` pair, so light and dark
/// mode each get a readable contrast without hard-coded values.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balanceCents,
    required this.cashBalanceCents,
    required this.savingsBalanceCents,
    required this.incomeCents,
    required this.expenseCents,
    required this.currency,
  });

  final int balanceCents;
  final int cashBalanceCents;
  final int savingsBalanceCents;
  final int incomeCents;
  final int expenseCents;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final onCard = colors.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Balance · ${currency.code}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onCard.withValues(alpha: 0.75),
                  ),
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 20,
                color: onCard.withValues(alpha: 0.75),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatCents(balanceCents, currency),
              style: theme.textTheme.displaySmall?.copyWith(color: onCard),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _Summary(
                  label: 'Remaining',
                  amountCents: cashBalanceCents,
                  icon: Icons.account_balance_wallet_outlined,
                  color: onCard,
                  currency: currency,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _Summary(
                  label: 'Savings',
                  amountCents: savingsBalanceCents,
                  icon: Icons.savings_outlined,
                  color: onCard,
                  currency: currency,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 1, color: onCard.withValues(alpha: 0.2)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _Summary(
                  label: 'Income',
                  amountCents: incomeCents,
                  icon: Icons.south_west_rounded,
                  color: onCard,
                  currency: currency,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _Summary(
                  label: 'Expense',
                  amountCents: expenseCents,
                  icon: Icons.north_east_rounded,
                  color: onCard,
                  currency: currency,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
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

    return Row(
      children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatCents(amountCents, currency),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
