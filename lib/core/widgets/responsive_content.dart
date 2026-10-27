import 'package:flutter/material.dart';

/// Constrains page content to a comfortable reading width on larger screens.
///
/// On phones this is a no-op: the content keeps the full viewport width. On
/// tablets and desktop browsers it stays centered instead of stretching cards
/// and form fields across the window.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 720,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
