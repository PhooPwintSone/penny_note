import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../constants/app_constants.dart';
import 'daos/account_dao.dart';
import 'daos/category_dao.dart';
import 'daos/expense_dao.dart';
import 'daos/income_category_dao.dart';
import 'daos/income_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/transfer_dao.dart';
import 'tables/accounts.dart';
import 'tables/app_settings.dart';
import 'tables/categories.dart';
import 'tables/expenses.dart';
import 'tables/income_categories.dart';
import 'tables/incomes.dart';
import 'tables/transfers.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Expenses,
    Accounts,
    Transfers,
    IncomeCategories,
    Incomes,
    AppSettings,
  ],
  daos: [
    CategoryDao,
    ExpenseDao,
    AccountDao,
    TransferDao,
    IncomeCategoryDao,
    IncomeDao,
    SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Used by tests to inject an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
        await _seedDefaultCategories();
        await _seedDefaultIncomeCategories();
        await _seedDefaultAccounts();
        await _seedDefaultAppSettings();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 3) {
          await migrator.createTable(incomeCategories);
          await migrator.createTable(incomes);
          await _seedDefaultIncomeCategories();
        }
        if (from < 4) {
          await migrator.createTable(accounts);
          await _seedDefaultAccounts();
          await migrator.createTable(transfers);
          await _migrateSavingsEntries();
        }
        if (from < 5) {
          await migrator.createTable(appSettings);
          await _seedDefaultAppSettings();
        }
      },
      beforeOpen: (details) async {
        // SQLite requires foreign keys to be enabled on every connection.
        await customStatement('PRAGMA foreign_keys = ON');
        // Keep the two built-in accounts present even if a previous launch was
        // interrupted. The unique code makes this idempotent.
        await _seedDefaultAccounts();
        // A single settings row holds the selected currency.
        await _seedDefaultAppSettings();
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

  Future<void> _seedDefaultAccounts() async {
    await customStatement(
      "INSERT OR IGNORE INTO accounts (code, name) "
      "VALUES ('cash', 'Cash'), ('savings', 'Savings')",
    );
  }

  Future<void> _seedDefaultAppSettings() async {
    await customStatement(
      "INSERT OR IGNORE INTO app_settings (id, currency_code) "
      "VALUES (1, 'MMK')",
    );
  }

  /// Copies the old deposit/withdrawal ledger into the new transfer ledger
  /// before removing the legacy table. Existing amounts, notes, and dates are
  /// preserved; deposits become Cash -> Savings and withdrawals become
  /// Savings -> Cash.
  Future<void> _migrateSavingsEntries() async {
    if (!await _tableExists('savings_entries')) return;

    await customStatement('''
      INSERT INTO transfers (
        amount_cents,
        from_account_id,
        to_account_id,
        note,
        date,
        created_at,
        updated_at
      )
      SELECT
        s.amount_cents,
        CASE WHEN s.is_withdrawal = 0 THEN cash.id ELSE savings.id END,
        CASE WHEN s.is_withdrawal = 0 THEN savings.id ELSE cash.id END,
        s.note,
        s.date,
        s.created_at,
        s.updated_at
      FROM savings_entries s
      CROSS JOIN (SELECT id FROM accounts WHERE code = 'cash') cash
      CROSS JOIN (SELECT id FROM accounts WHERE code = 'savings') savings
    ''');

    await customStatement('DROP TABLE savings_entries');
  }

  Future<bool> _tableExists(String tableName) async {
    final row = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable.withString(tableName)],
    ).getSingleOrNull();
    return row != null;
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
