import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// The standard rounded surface used across the app.
///
/// Cards use a solid paper-like surface, a thin contrasting outline, and a
/// hard offset shadow so they read like vintage journal cards rather than
/// elevated Material surfaces.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppSpacing.cardRadius);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius,
        border: Border.all(color: colors.outline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.22),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
