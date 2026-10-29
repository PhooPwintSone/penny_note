// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_category_dao.dart';

// ignore_for_file: type=lint
mixin _$IncomeCategoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $IncomeCategoriesTable get incomeCategories =>
      attachedDatabase.incomeCategories;
  $IncomesTable get incomes => attachedDatabase.incomes;
  IncomeCategoryDaoManager get managers => IncomeCategoryDaoManager(this);
}

class IncomeCategoryDaoManager {
  final _$IncomeCategoryDaoMixin _db;
  IncomeCategoryDaoManager(this._db);
  $$IncomeCategoriesTableTableManager get incomeCategories =>
      $$IncomeCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.incomeCategories,
      );
  $$IncomesTableTableManager get incomes =>
      $$IncomesTableTableManager(_db.attachedDatabase, _db.incomes);
}
