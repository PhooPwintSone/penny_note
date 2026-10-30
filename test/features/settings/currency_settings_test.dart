import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/database/app_database.dart';
import 'package:penny_note/core/errors/app_failure.dart';
import 'package:penny_note/core/utils/money.dart';
import 'package:penny_note/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:penny_note/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:penny_note/features/settings/domain/repositories/settings_repository.dart';
import 'package:penny_note/features/settings/domain/usecases/update_currency.dart';

void main() {
  late AppDatabase database;
  late SettingsRepository repository;
  late UpdateCurrency updateCurrency;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SettingsRepositoryImpl(
      SettingsLocalDataSource(database.settingsDao),
    );
    updateCurrency = UpdateCurrency(repository);
  });

  tearDown(() => database.close());

  test('defaults to MMK', () async {
    final settings = await repository.watchSettings().first;

    expect(settings.currency, AppCurrency.mmk);
  });

  test('supports exactly five currencies', () {
    expect(AppCurrency.values, hasLength(5));
    expect(AppCurrency.values.map((currency) => currency.code), [
      'MMK',
      'USD',
      'CAD',
      'SGD',
      'THB',
    ]);
  });

  test('allows changing currency when the ledger is empty', () async {
    await updateCurrency(AppCurrency.usd);

    final settings = await repository.watchSettings().first;
    expect(settings.currency, AppCurrency.usd);
  });

  test(
    'blocks currency changes when records exist and keeps them intact',
    () async {
      final categories = await database.categoryDao.watchAll().first;
      final food = categories.firstWhere((category) => category.name == 'Food');
      await database.expenseDao.insertExpense(
        ExpensesCompanion.insert(
          amountCents: 1250,
          categoryId: food.id,
          note: const Value('Lunch'),
          date: DateTime(2026, 10, 27),
        ),
      );

      final beforeSummary = await database.accountDao.currentSummary();

      await expectLater(
        updateCurrency(AppCurrency.usd),
        throwsA(isA<ValidationFailure>()),
      );

      final settings = await repository.watchSettings().first;
      expect(settings.currency, AppCurrency.mmk);

      final expenses = await database.expenseDao.watchAll().first;
      expect(expenses, hasLength(1));
      expect(expenses.single.expense.amountCents, 1250);
      expect(expenses.single.expense.note, 'Lunch');

      final afterSummary = await database.accountDao.currentSummary();
      expect(afterSummary.cashBalanceCents, beforeSummary.cashBalanceCents);
      expect(afterSummary.totalExpenseCents, beforeSummary.totalExpenseCents);
    },
  );

  test('persists the selected currency across database restarts', () async {
    final directory = await Directory.systemTemp.createTemp(
      'penny_note_currency_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/penny_note.sqlite');

    var db = AppDatabase.forTesting(NativeDatabase(file));
    var repo = SettingsRepositoryImpl(SettingsLocalDataSource(db.settingsDao));
    await UpdateCurrency(repo)(AppCurrency.thb);
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);
    repo = SettingsRepositoryImpl(SettingsLocalDataSource(db.settingsDao));

    final settings = await repo.watchSettings().first;
    expect(settings.currency, AppCurrency.thb);
  });
}
