/// A spending category, e.g. Food or Transport.
///
/// Part of the domain layer: it has no Flutter or Drift imports.
class Category {
  const Category({required this.id, required this.name, required this.icon});

  final int id;
  final String name;

  /// Stable icon key, resolved to an [IconData] in the UI layer.
  final String icon;
}
