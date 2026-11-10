/// One category's contribution to a monthly income or expense total.
class CategoryTotal {
  const CategoryTotal({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.amountCents,
  });

  final int categoryId;
  final String name;

  /// Stable icon key, resolved to an [IconData] in the UI layer.
  final String icon;
  final int amountCents;
}

/// Income and expense totals for one calendar month.
class MonthlyTotal {
  const MonthlyTotal({
    required this.month,
    required this.incomeCents,
    required this.expenseCents,
  });

  /// The first day of the month this total belongs to.
  final DateTime month;
  final int incomeCents;
  final int expenseCents;

  int get netCents => incomeCents - expenseCents;

  bool get hasActivity => incomeCents > 0 || expenseCents > 0;
}

/// Everything the Statistics screen needs for one selected month.
class StatisticsSnapshot {
  const StatisticsSnapshot({
    required this.month,
    required this.incomeCents,
    required this.expenseCents,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.trend,
  });

  /// The first day of the selected month.
  final DateTime month;
  final int incomeCents;
  final int expenseCents;
  final List<CategoryTotal> expenseCategories;
  final List<CategoryTotal> incomeCategories;

  /// Oldest to newest, ending at [month].
  final List<MonthlyTotal> trend;

  int get netCents => incomeCents - expenseCents;

  bool get hasActivity => incomeCents > 0 || expenseCents > 0;
}
