import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../constants/app_constants.dart';
import 'daos/category_dao.dart';
import 'daos/expense_dao.dart';
import 'daos/income_category_dao.dart';
import 'daos/income_dao.dart';
import 'daos/savings_dao.dart';
import 'tables/categories.dart';
import 'tables/expenses.dart';
import 'tables/income_categories.dart';
import 'tables/incomes.dart';
import 'tables/savings_entries.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, Expenses, SavingsEntries, IncomeCategories, Incomes],
  daos: [CategoryDao, ExpenseDao, SavingsDao, IncomeCategoryDao, IncomeDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Used by tests to inject an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
        await _seedDefaultCategories();
        await _seedDefaultIncomeCategories();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(savingsEntries);
        }
        if (from < 3) {
          await migrator.createTable(incomeCategories);
          await migrator.createTable(incomes);
          await _seedDefaultIncomeCategories();
        }
      },
      beforeOpen: (details) async {
        // SQLite requires foreign keys to be enabled on every connection.
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _seedDefaultCategories() async {
    await batch((batch) {
      batch.insertAll(categories, const [
        CategoriesCompanion(name: Value('Food'), icon: Value('restaurant')),
        CategoriesCompanion(
          name: Value('Transport'),
          icon: Value('directions_bus'),
        ),
        CategoriesCompanion(
          name: Value('Shopping'),
          icon: Value('shopping_bag'),
        ),
        CategoriesCompanion(name: Value('Bills'), icon: Value('receipt_long')),
        CategoriesCompanion(name: Value('Health'), icon: Value('favorite')),
        CategoriesCompanion(name: Value('Coffee'), icon: Value('local_cafe')),
        CategoriesCompanion(name: Value('Other'), icon: Value('category')),
      ]);
    });
  }

  Future<void> _seedDefaultIncomeCategories() async {
    await batch((batch) {
      batch.insertAll(incomeCategories, const [
        IncomeCategoriesCompanion(
          name: Value('Salary'),
          icon: Value('payments'),
        ),
        IncomeCategoriesCompanion(
          name: Value('Freelance'),
          icon: Value('work'),
        ),
        IncomeCategoriesCompanion(
          name: Value('Business'),
          icon: Value('business_center'),
        ),
        IncomeCategoriesCompanion(
          name: Value('Gifts'),
          icon: Value('card_giftcard'),
        ),
        IncomeCategoriesCompanion(
          name: Value('Interest'),
          icon: Value('trending_up'),
        ),
        IncomeCategoriesCompanion(
          name: Value('Other'),
          icon: Value('category'),
        ),
      ]);
    });
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: AppConstants.databaseName,
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
