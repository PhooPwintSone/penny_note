import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A section title with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: 28,
            height: 1.5,
            decoration: BoxDecoration(
              color: colors.tertiary.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
