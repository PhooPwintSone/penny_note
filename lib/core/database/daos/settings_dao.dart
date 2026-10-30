import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/app_settings.dart';
import '../tables/expenses.dart';
import '../tables/incomes.dart';
import '../tables/transfers.dart';

part 'settings_dao.g.dart';

/// Reads and writes the single app-settings row.
@DriftAccessor(tables: [AppSettings, Expenses, Incomes, Transfers])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Stream<AppSettingsRow> watchSettings() {
    return (select(
      appSettings,
    )..where((row) => row.id.equals(1))).watchSingle();
  }

  Future<void> updateCurrency(String currencyCode) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        id: const Value(1),
        currencyCode: Value(currencyCode),
      ),
    );
  }

  /// Emits whether any financial ledger row exists.
  ///
  /// Accounts are intentionally excluded: the built-in Cash and Savings
  /// accounts always exist, but they are not financial records.
  Stream<bool> watchHasFinancialRecords() {
    return customSelect(
      '''
      SELECT (
        EXISTS(SELECT 1 FROM expenses)
        OR EXISTS(SELECT 1 FROM incomes)
        OR EXISTS(SELECT 1 FROM transfers)
      ) AS has_records
      ''',
      readsFrom: {expenses, incomes, transfers},
    ).watchSingle().map((row) => row.read<int>('has_records') == 1);
  }
}
