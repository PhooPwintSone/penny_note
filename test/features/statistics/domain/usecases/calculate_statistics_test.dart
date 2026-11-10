import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/features/categories/domain/entities/category.dart';
import 'package:penny_note/features/expenses/domain/entities/expense.dart';
import 'package:penny_note/features/income/domain/entities/income.dart';
import 'package:penny_note/features/income/domain/entities/income_category.dart';
import 'package:penny_note/features/statistics/domain/usecases/calculate_statistics.dart';

void main() {
  const calculator = CalculateStatistics();
  const food = Category(id: 1, name: 'Food', icon: 'restaurant');
  const transport = Category(id: 2, name: 'Transport', icon: 'directions_bus');
  const salary = IncomeCategory(id: 1, name: 'Salary', icon: 'payments');

  Expense expense({
    required int id,
    required int amountCents,
    required Category category,
    required DateTime date,
  }) {
    return Expense(
      id: id,
      amountCents: amountCents,
      category: category,
      note: '',
      date: date,
      createdAt: date,
      updatedAt: date,
    );
  }

  Income income({
    required int id,
    required int amountCents,
    required IncomeCategory category,
    required DateTime date,
  }) {
    return Income(
      id: id,
      amountCents: amountCents,
      category: category,
      note: '',
      date: date,
      createdAt: date,
      updatedAt: date,
    );
  }

  test('sums the selected month and ranks category totals', () {
    final snapshot = calculator(
      month: DateTime(2026, 11),
      expenses: [
        expense(
          id: 1,
          amountCents: 500,
          category: food,
          date: DateTime(2026, 11, 2),
        ),
        expense(
          id: 2,
          amountCents: 300,
          category: food,
          date: DateTime(2026, 11, 9),
        ),
        expense(
          id: 3,
          amountCents: 200,
          category: transport,
          date: DateTime(2026, 11, 10),
        ),
        expense(
          id: 4,
          amountCents: 999,
          category: food,
          date: DateTime(2026, 10, 31),
        ),
      ],
      incomes: [
        income(
          id: 1,
          amountCents: 2000,
          category: salary,
          date: DateTime(2026, 11, 1),
        ),
        income(
          id: 2,
          amountCents: 500,
          category: salary,
          date: DateTime(2026, 12, 1),
        ),
      ],
    );

    expect(snapshot.month, DateTime(2026, 11));
    expect(snapshot.expenseCents, 1000);
    expect(snapshot.incomeCents, 2000);
    expect(snapshot.netCents, 1000);
    expect(snapshot.expenseCategories, hasLength(2));
    expect(snapshot.expenseCategories.first.name, 'Food');
    expect(snapshot.expenseCategories.first.amountCents, 800);
    expect(snapshot.expenseCategories.last.name, 'Transport');
    expect(snapshot.expenseCategories.last.amountCents, 200);
    expect(snapshot.incomeCategories.single.name, 'Salary');
    expect(snapshot.incomeCategories.single.amountCents, 2000);
  });

  test('builds a six-month trend ending at the selected month', () {
    final snapshot = calculator(
      month: DateTime(2026, 11),
      expenses: [
        expense(
          id: 1,
          amountCents: 500,
          category: food,
          date: DateTime(2026, 11, 2),
        ),
        expense(
          id: 2,
          amountCents: 300,
          category: food,
          date: DateTime(2026, 6, 15),
        ),
      ],
      incomes: [
        income(
          id: 1,
          amountCents: 2000,
          category: salary,
          date: DateTime(2026, 11, 1),
        ),
      ],
    );

    expect(snapshot.trend, hasLength(6));
    expect(snapshot.trend.map((point) => point.month), [
      DateTime(2026, 6),
      DateTime(2026, 7),
      DateTime(2026, 8),
      DateTime(2026, 9),
      DateTime(2026, 10),
      DateTime(2026, 11),
    ]);
    expect(snapshot.trend.first.expenseCents, 300);
    expect(snapshot.trend.last.incomeCents, 2000);
    expect(snapshot.trend.last.expenseCents, 500);
  });

  test('trend crosses a year boundary', () {
    final snapshot = calculator(
      month: DateTime(2027, 2),
      expenses: const [],
      incomes: const [],
    );

    expect(snapshot.trend.map((point) => point.month), [
      DateTime(2026, 9),
      DateTime(2026, 10),
      DateTime(2026, 11),
      DateTime(2026, 12),
      DateTime(2027, 1),
      DateTime(2027, 2),
    ]);
  });

  test('returns an empty snapshot for a month without entries', () {
    final snapshot = calculator(
      month: DateTime(2026, 11),
      expenses: const [],
      incomes: const [],
    );

    expect(snapshot.hasActivity, isFalse);
    expect(snapshot.expenseCents, 0);
    expect(snapshot.incomeCents, 0);
    expect(snapshot.expenseCategories, isEmpty);
    expect(snapshot.incomeCategories, isEmpty);
    expect(snapshot.trend.every((point) => !point.hasActivity), isTrue);
  });
}
