// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_dao.dart';

// ignore_for_file: type=lint
mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppSettingsTable get appSettings => attachedDatabase.appSettings;
  $CategoriesTable get categories => attachedDatabase.categories;
  $ExpensesTable get expenses => attachedDatabase.expenses;
  $IncomeCategoriesTable get incomeCategories =>
      attachedDatabase.incomeCategories;
  $IncomesTable get incomes => attachedDatabase.incomes;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $TransfersTable get transfers => attachedDatabase.transfers;
  SettingsDaoManager get managers => SettingsDaoManager(this);
}

class SettingsDaoManager {
  final _$SettingsDaoMixin _db;
  SettingsDaoManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db.attachedDatabase, _db.appSettings);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
  $$IncomeCategoriesTableTableManager get incomeCategories =>
      $$IncomeCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.incomeCategories,
      );
  $$IncomesTableTableManager get incomes =>
      $$IncomesTableTableManager(_db.attachedDatabase, _db.incomes);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$TransfersTableTableManager get transfers =>
      $$TransfersTableTableManager(_db.attachedDatabase, _db.transfers);
}
