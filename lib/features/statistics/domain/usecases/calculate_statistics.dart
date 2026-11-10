import '../../../expenses/domain/entities/expense.dart';
import '../../../income/domain/entities/income.dart';
import '../entities/statistics.dart';

/// Pure aggregation of expense and income entries for the Statistics screen.
///
/// Transfers are deliberately excluded: moving money between Cash and Savings
/// is not income or an expense.
class CalculateStatistics {
  const CalculateStatistics();

  StatisticsSnapshot call({
    required DateTime month,
    required List<Expense> expenses,
    required List<Income> incomes,
    int trendMonthCount = 6,
  }) {
    assert(trendMonthCount > 0);

    final selectedMonth = _monthOnly(month);
    final monthExpenses = expenses
        .where((expense) => _isSameMonth(expense.date, selectedMonth))
        .toList(growable: false);
    final monthIncomes = incomes
        .where((income) => _isSameMonth(income.date, selectedMonth))
        .toList(growable: false);

    return StatisticsSnapshot(
      month: selectedMonth,
      incomeCents: monthIncomes.fold(
        0,
        (total, income) => total + income.amountCents,
      ),
      expenseCents: monthExpenses.fold(
        0,
        (total, expense) => total + expense.amountCents,
      ),
      expenseCategories: _expenseCategories(monthExpenses),
      incomeCategories: _incomeCategories(monthIncomes),
      trend: _trend(
        selectedMonth: selectedMonth,
        expenses: expenses,
        incomes: incomes,
        monthCount: trendMonthCount,
      ),
    );
  }

  List<CategoryTotal> _expenseCategories(List<Expense> expenses) {
    final totals = <int, CategoryTotal>{};
    for (final expense in expenses) {
      final category = expense.category;
      final previous = totals[category.id]?.amountCents ?? 0;
      totals[category.id] = CategoryTotal(
        categoryId: category.id,
        name: category.name,
        icon: category.icon,
        amountCents: previous + expense.amountCents,
      );
    }
    return _sortedTotals(totals.values);
  }

  List<CategoryTotal> _incomeCategories(List<Income> incomes) {
    final totals = <int, CategoryTotal>{};
    for (final income in incomes) {
      final category = income.category;
      final previous = totals[category.id]?.amountCents ?? 0;
      totals[category.id] = CategoryTotal(
        categoryId: category.id,
        name: category.name,
        icon: category.icon,
        amountCents: previous + income.amountCents,
      );
    }
    return _sortedTotals(totals.values);
  }

  List<CategoryTotal> _sortedTotals(Iterable<CategoryTotal> totals) {
    final sorted = totals.toList()
      ..sort((a, b) {
        final byAmount = b.amountCents.compareTo(a.amountCents);
        if (byAmount != 0) return byAmount;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return List.unmodifiable(sorted);
  }

  List<MonthlyTotal> _trend({
    required DateTime selectedMonth,
    required List<Expense> expenses,
    required List<Income> incomes,
    required int monthCount,
  }) {
    final points = <MonthlyTotal>[];
    for (var offset = monthCount - 1; offset >= 0; offset--) {
      final month = DateTime(selectedMonth.year, selectedMonth.month - offset);
      final incomeCents = incomes
          .where((income) => _isSameMonth(income.date, month))
          .fold(0, (total, income) => total + income.amountCents);
      final expenseCents = expenses
          .where((expense) => _isSameMonth(expense.date, month))
          .fold(0, (total, expense) => total + expense.amountCents);

      points.add(
        MonthlyTotal(
          month: month,
          incomeCents: incomeCents,
          expenseCents: expenseCents,
        ),
      );
    }
    return List.unmodifiable(points);
  }
}

DateTime _monthOnly(DateTime date) => DateTime(date.year, date.month);

bool _isSameMonth(DateTime date, DateTime month) {
  return date.year == month.year && date.month == month.month;
}
