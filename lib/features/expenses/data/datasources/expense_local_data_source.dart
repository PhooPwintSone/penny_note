import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/expense_dao.dart';
import '../../../../core/errors/app_failure.dart';
import '../models/expense_model.dart';

/// Talks to Drift through [ExpenseDao] and returns data-layer models.
///
/// Keeping this thin wrapper means the repository never touches Drift types,
/// and queries have one obvious home.
class ExpenseLocalDataSource {
  const ExpenseLocalDataSource(this._dao);

  final ExpenseDao _dao;

  Stream<List<ExpenseModel>> watchExpenses() {
    return _dao.watchAll().map(
      (rows) => rows.map(ExpenseModel.fromRow).toList(growable: false),
    );
  }

  Future<void> addExpense({
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) async {
    final now = DateTime.now();
    await _dao.insertExpense(
      ExpensesCompanion.insert(
        amountCents: amountCents,
        categoryId: categoryId,
        date: date,
        note: Value(note),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> deleteExpense(int id) async {
    final deleted = await _dao.deleteExpense(id);
    if (!deleted) {
      throw const DatabaseFailure('That expense no longer exists.');
    }
  }

  Future<void> updateExpense({
    required int id,
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) async {
    final updated = await _dao.updateExpense(
      id,
      ExpensesCompanion(
        amountCents: Value(amountCents),
        categoryId: Value(categoryId),
        note: Value(note),
        date: Value(date),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (!updated) {
      throw const DatabaseFailure('That expense no longer exists.');
    }
  }
}
