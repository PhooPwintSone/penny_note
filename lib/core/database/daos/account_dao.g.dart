// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_dao.dart';

// ignore_for_file: type=lint
mixin _$AccountDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccountsTable get accounts => attachedDatabase.accounts;
  $IncomeCategoriesTable get incomeCategories =>
      attachedDatabase.incomeCategories;
  $IncomesTable get incomes => attachedDatabase.incomes;
  $CategoriesTable get categories => attachedDatabase.categories;
  $ExpensesTable get expenses => attachedDatabase.expenses;
  $TransfersTable get transfers => attachedDatabase.transfers;
  AccountDaoManager get managers => AccountDaoManager(this);
}

class AccountDaoManager {
  final _$AccountDaoMixin _db;
  AccountDaoManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$IncomeCategoriesTableTableManager get incomeCategories =>
      $$IncomeCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.incomeCategories,
      );
  $$IncomesTableTableManager get incomes =>
      $$IncomesTableTableManager(_db.attachedDatabase, _db.incomes);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
  $$TransfersTableTableManager get transfers =>
      $$TransfersTableTableManager(_db.attachedDatabase, _db.transfers);
}
