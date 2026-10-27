import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// The standard rounded surface used across the app.
///
/// Colors, borders and radius come from [AppTheme]'s card theme, so widgets
/// never need to pick a surface color themselves.
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
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
