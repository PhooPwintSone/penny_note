/// An income category, e.g. Salary or Freelance.
///
/// Part of the domain layer: it has no Flutter or Drift imports.
class IncomeCategory {
  const IncomeCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  final int id;
  final String name;

  /// Stable icon key, resolved to an [IconData] in the UI layer.
  final String icon;
}
