import '../../../categories/domain/entities/category.dart';

/// A single expense entry.
///
/// Money is kept as integer cents so totals never suffer from floating point
/// rounding. Format it with `formatCents` for display.
class Expense {
  const Expense({
    required this.id,
    required this.amountCents,
    required this.category,
    required this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int amountCents;
  final Category category;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
}
