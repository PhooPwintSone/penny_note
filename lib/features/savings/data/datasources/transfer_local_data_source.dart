import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/transfer_dao.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../accounts/domain/entities/account.dart';
import '../models/transfer_model.dart';

class TransferLocalDataSource {
  const TransferLocalDataSource(this._dao);

  final TransferDao _dao;

  Stream<List<TransferModel>> watchTransfers() {
    return _dao.watchAll().map(
      (rows) => rows.map(TransferModel.fromRow).toList(growable: false),
    );
  }

  Future<void> addTransfer({
    required int amountCents,
    required Account from,
    required Account to,
    required String note,
    required DateTime date,
  }) async {
    final now = DateTime.now();
    await _dao.insertTransfer(
      TransfersCompanion.insert(
        amountCents: amountCents,
        fromAccountId: from.id,
        toAccountId: to.id,
        note: Value(note),
        date: date,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> updateTransfer({
    required int id,
    required int amountCents,
    required Account from,
    required Account to,
    required String note,
    required DateTime date,
  }) async {
    final updated = await _dao.updateTransfer(
      id,
      TransfersCompanion(
        amountCents: Value(amountCents),
        fromAccountId: Value(from.id),
        toAccountId: Value(to.id),
        note: Value(note),
        date: Value(date),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (!updated) {
      throw const DatabaseFailure('That transfer no longer exists.');
    }
  }

  Future<void> deleteTransfer(int id) async {
    final deleted = await _dao.deleteTransfer(id);
    if (!deleted) {
      throw const DatabaseFailure('That transfer no longer exists.');
    }
  }

  Future<TransferModel?> findById(int id) async {
    final row = await _dao.findById(id);
    return row == null ? null : TransferModel.fromRow(row);
  }
}
