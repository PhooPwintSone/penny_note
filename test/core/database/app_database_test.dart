import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/database/app_database.dart';
import 'package:penny_note/features/expenses/data/datasources/expense_local_data_source.dart';
import 'package:penny_note/features/income/data/datasources/income_local_data_source.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('uses schema version 3 with savings and income tables', () async {
    expect(database.schemaVersion, 3);

    await database.savingsDao.insertEntry(
      SavingsEntriesCompanion.insert(
        amountCents: 750,
        date: DateTime(2026, 10, 27),
      ),
    );

    expect(await database.savingsDao.totalCents(), 750);

    final incomeCategories = await database.incomeCategoryDao.watchAll().first;
    expect(
      incomeCategories.map((category) => category.name),
      containsAll(['Salary', 'Freelance', 'Business', 'Gifts', 'Interest']),
    );
  });

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

  test(
    'joins income categories and is reactive to inserts and deletes',
    () async {
      final categories = await database.incomeCategoryDao.watchAll().first;
      final salary = categories.firstWhere(
        (category) => category.name == 'Salary',
      );
      final dataSource = IncomeLocalDataSource(database.incomeDao);

      await dataSource.addIncome(
        amountCents: 250000,
        categoryId: salary.id,
        note: 'October salary',
        date: DateTime(2026, 10, 27),
      );

      final incomes = await dataSource.watchIncomes().first;
      expect(incomes, hasLength(1));
      expect(incomes.single.amountCents, 250000);
      expect(incomes.single.category.name, 'Salary');
      expect(incomes.single.note, 'October salary');

      await dataSource.deleteIncome(incomes.single.id);
      expect(await dataSource.watchIncomes().first, isEmpty);
    },
  );
}
