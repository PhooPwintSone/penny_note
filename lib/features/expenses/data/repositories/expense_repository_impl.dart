import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl(this._localDataSource);

  final ExpenseLocalDataSource _localDataSource;

  @override
  Stream<List<Expense>> watchExpenses() {
    return _localDataSource
        .watchExpenses()
        .map(
          (models) =>
              models.map((model) => model.toEntity()).toList(growable: false),
        )
        .handleError((Object _, StackTrace _) {
          throw const DatabaseFailure('Could not read your saved expenses.');
        });
  }

  @override
  Future<void> addExpense({
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) async {
    try {
      await _localDataSource.addExpense(
        amountCents: amountCents,
        categoryId: categoryId,
        note: note,
        date: date,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not save this expense.');
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    try {
      await _localDataSource.deleteExpense(id);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not delete this expense.');
    }
  }

  @override
  Future<void> updateExpense({
    required int id,
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) async {
    try {
      await _localDataSource.updateExpense(
        id: id,
        amountCents: amountCents,
        categoryId: categoryId,
        note: note,
        date: date,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not update this expense.');
    }
  }

  @override
  Future<int?> amountCentsById(int id) async {
    try {
      return await _localDataSource.amountCentsById(id);
    } catch (_) {
      throw const DatabaseFailure('Could not read that expense.');
    }
  }
}
