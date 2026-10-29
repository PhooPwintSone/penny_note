import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/income_dao.dart';
import '../../../../core/errors/app_failure.dart';
import '../models/income_model.dart';

/// Talks to Drift through [IncomeDao] and returns data-layer models.
class IncomeLocalDataSource {
  const IncomeLocalDataSource(this._dao);

  final IncomeDao _dao;

  Stream<List<IncomeModel>> watchIncomes() {
    return _dao.watchAll().map(
      (rows) => rows.map(IncomeModel.fromRow).toList(growable: false),
    );
  }

  Future<void> addIncome({
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) async {
    final now = DateTime.now();
    await _dao.insertIncome(
      IncomesCompanion.insert(
        amountCents: amountCents,
        categoryId: categoryId,
        date: date,
        note: Value(note),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> deleteIncome(int id) async {
    final deleted = await _dao.deleteIncome(id);
    if (!deleted) {
      throw const DatabaseFailure('That income entry no longer exists.');
    }
  }

  Future<void> updateIncome({
    required int id,
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) async {
    final updated = await _dao.updateIncome(
      id,
      IncomesCompanion(
        amountCents: Value(amountCents),
        categoryId: Value(categoryId),
        note: Value(note),
        date: Value(date),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (!updated) {
      throw const DatabaseFailure('That income entry no longer exists.');
    }
  }
}
