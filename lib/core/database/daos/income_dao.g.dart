// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_dao.dart';

// ignore_for_file: type=lint
mixin _$IncomeDaoMixin on DatabaseAccessor<AppDatabase> {
  $IncomeCategoriesTable get incomeCategories =>
      attachedDatabase.incomeCategories;
  $IncomesTable get incomes => attachedDatabase.incomes;
  IncomeDaoManager get managers => IncomeDaoManager(this);
}

class IncomeDaoManager {
  final _$IncomeDaoMixin _db;
  IncomeDaoManager(this._db);
  $$IncomeCategoriesTableTableManager get incomeCategories =>
      $$IncomeCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.incomeCategories,
      );
  $$IncomesTableTableManager get incomes =>
      $$IncomesTableTableManager(_db.attachedDatabase, _db.incomes);
}
