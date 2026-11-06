import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A calm, centered placeholder for sections without data yet.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: colors.tertiary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: colors.tertiary.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, size: 30, color: colors.primary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(letterSpacing: 0.1),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ],
        if (action != null) ...[const SizedBox(height: AppSpacing.xl), action!],
      ],
    );
  }
}
