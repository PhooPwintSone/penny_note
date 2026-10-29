import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/database/app_database.dart';

void main() {
  test('migrates a version 2 database and seeds income categories', () async {
    final executor = NativeDatabase.memory(
      setup: (rawDatabase) {
        rawDatabase.execute('PRAGMA user_version = 2');
      },
    );
    final database = AppDatabase.forTesting(executor);
    addTearDown(database.close);

    final categories = await database.incomeCategoryDao.watchAll().first;
    expect(
      categories.map((category) => category.name),
      containsAll(['Salary', 'Freelance', 'Business', 'Gifts', 'Interest']),
    );

    final salary = categories.firstWhere(
      (category) => category.name == 'Salary',
    );
    await database.incomeDao.insertIncome(
      IncomesCompanion.insert(
        amountCents: 500,
        categoryId: salary.id,
        date: DateTime(2026, 10, 27),
      ),
    );
    expect(await database.incomeDao.watchAll().first, hasLength(1));
  });
}
