import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/database/app_database.dart';
import 'package:penny_note/features/expenses/data/datasources/expense_local_data_source.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('seeds the default categories on first open', () async {
    final categories = await database.categoryDao.watchAll().first;

    expect(
      categories.map((category) => category.name),
      containsAll(['Food', 'Transport', 'Shopping', 'Bills', 'Health']),
    );
  });

  test('joins categories and is reactive to inserts and deletes', () async {
    final categories = await database.categoryDao.watchAll().first;
    final food = categories.firstWhere((category) => category.name == 'Food');
    final dataSource = ExpenseLocalDataSource(database.expenseDao);

    await dataSource.addExpense(
      amountCents: 1250,
      categoryId: food.id,
      note: 'Lunch',
      date: DateTime(2026, 10, 27),
    );

    final expenses = await dataSource.watchExpenses().first;
    expect(expenses, hasLength(1));
    expect(expenses.single.amountCents, 1250);
    expect(expenses.single.category.name, 'Food');
    expect(expenses.single.note, 'Lunch');

    await dataSource.deleteExpense(expenses.single.id);
    expect(await dataSource.watchExpenses().first, isEmpty);
  });
}
