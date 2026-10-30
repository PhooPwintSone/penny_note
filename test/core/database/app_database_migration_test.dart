import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/database/app_database.dart';

void main() {
  test(
    'migrates a version 2 database without losing existing records',
    () async {
      final now = DateTime(2026, 10, 1).millisecondsSinceEpoch ~/ 1000;
      final executor = NativeDatabase.memory(
        setup: (rawDatabase) {
          rawDatabase.execute('PRAGMA user_version = 2');
          rawDatabase.execute('''
          CREATE TABLE categories (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            icon TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
          rawDatabase.execute('''
          CREATE TABLE expenses (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            amount_cents INTEGER NOT NULL,
            category_id INTEGER NOT NULL REFERENCES categories(id),
            note TEXT NOT NULL DEFAULT '',
            date INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
          rawDatabase.execute('''
          CREATE TABLE savings_entries (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            amount_cents INTEGER NOT NULL,
            is_withdrawal INTEGER NOT NULL DEFAULT 0,
            note TEXT NOT NULL DEFAULT '',
            date INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
          rawDatabase.execute(
            "INSERT INTO categories (name, icon, created_at) "
            "VALUES ('Food', 'restaurant', $now)",
          );
          rawDatabase.execute(
            "INSERT INTO expenses "
            "(amount_cents, category_id, note, date, created_at, updated_at) "
            "VALUES (1250, 1, 'Lunch', $now, $now, $now)",
          );
          rawDatabase.execute(
            "INSERT INTO savings_entries "
            "(amount_cents, is_withdrawal, note, date, created_at, updated_at) "
            "VALUES (1000, 0, 'Deposit', $now, $now, $now)",
          );
          rawDatabase.execute(
            "INSERT INTO savings_entries "
            "(amount_cents, is_withdrawal, note, date, created_at, updated_at) "
            "VALUES (400, 1, 'Withdrawal', $now, $now, $now)",
          );
        },
      );
      final database = AppDatabase.forTesting(executor);
      addTearDown(database.close);

      final settings = await database.settingsDao.watchSettings().first;
      expect(settings.currencyCode, 'MMK');

      final accounts = await database.accountDao.watchAccounts().first;
      expect(accounts, hasLength(2));
      expect(
        accounts.map((account) => account.code),
        containsAll(['cash', 'savings']),
      );

      final transfers = await database.transferDao.watchAll().first;
      expect(transfers, hasLength(2));

      final deposit = transfers.firstWhere(
        (row) => row.transfer.note == 'Deposit',
      );
      expect(deposit.transfer.amountCents, 1000);
      expect(deposit.fromAccount.code, 'cash');
      expect(deposit.toAccount.code, 'savings');

      final withdrawal = transfers.firstWhere(
        (row) => row.transfer.note == 'Withdrawal',
      );
      expect(withdrawal.transfer.amountCents, 400);
      expect(withdrawal.fromAccount.code, 'savings');
      expect(withdrawal.toAccount.code, 'cash');

      final expenses = await database.expenseDao.watchAll().first;
      expect(expenses, hasLength(1));
      expect(expenses.single.expense.note, 'Lunch');

      final incomeCategories = await database.incomeCategoryDao
          .watchAll()
          .first;
      expect(
        incomeCategories.map((category) => category.name),
        containsAll(['Salary', 'Freelance', 'Business', 'Gifts', 'Interest']),
      );

      final oldSavingsTable = await database
          .customSelect(
            "SELECT name FROM sqlite_master "
            "WHERE type = 'table' AND name = 'savings_entries'",
          )
          .getSingleOrNull();
      expect(oldSavingsTable, isNull);
    },
  );
}
