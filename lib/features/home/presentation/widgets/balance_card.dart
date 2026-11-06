import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money.dart';

/// The primary total, cash, and savings summary at the top of the dashboard.
///
/// Uses the same paper-like surface, outline, and hard offset shadow as the
/// rest of the journal cards. Income and expense totals are presented in
/// separate cards by the dashboard.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balanceCents,
    required this.cashBalanceCents,
    required this.savingsBalanceCents,
    required this.currency,
  });

  final int balanceCents;
  final int cashBalanceCents;
  final int savingsBalanceCents;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final onCard = colors.onSurface;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: colors.outline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.22),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Balance · ${currency.code}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onCard.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 20,
                color: colors.tertiary,
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
                  subLabel: 'Cash',
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
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.label,
    this.subLabel,
    required this.amountCents,
    required this.icon,
    required this.color,
    required this.currency,
  });

  final String label;
  final String? subLabel;
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
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color.withValues(alpha: 0.7),
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (subLabel != null)
                    Text(
                      ' · $subLabel',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color.withValues(alpha: 0.45),
                        letterSpacing: 0.4,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatCents(amountCents, currency),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
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
