import 'income_category.dart';

/// A single income entry.
///
/// Money is kept as integer cents so totals never suffer from floating point
/// rounding. Format it with `formatCents` for display.
class Income {
  const Income({
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
  final IncomeCategory category;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
}
