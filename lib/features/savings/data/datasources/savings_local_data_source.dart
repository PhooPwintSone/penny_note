import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/savings_dao.dart';
import '../../../../core/errors/app_failure.dart';
import '../models/savings_model.dart';

class SavingsLocalDataSource {
  const SavingsLocalDataSource(this._dao);

  final SavingsDao _dao;

  Stream<List<SavingsModel>> watchSavings() {
    return _dao.watchAll().map(
      (rows) => rows.map(SavingsModel.fromRow).toList(growable: false),
    );
  }

  Future<void> addSavings({
    required int amountCents,
    required bool isWithdrawal,
    required String note,
    required DateTime date,
  }) async {
    final now = DateTime.now();
    await _dao.insertEntry(
      SavingsEntriesCompanion.insert(
        amountCents: amountCents,
        isWithdrawal: Value(isWithdrawal),
        note: Value(note),
        date: date,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> deleteSavings(int id) async {
    final deleted = await _dao.deleteEntry(id);
    if (!deleted) {
      throw const DatabaseFailure('That savings entry no longer exists.');
    }
  }

  Future<int> totalSavingsCents() => _dao.totalCents();

  Future<SavingsModel?> findById(int id) async {
    final row = await _dao.entryById(id);
    return row == null ? null : SavingsModel.fromRow(row);
  }
}
