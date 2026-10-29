import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/income.dart';
import '../../domain/repositories/income_repository.dart';
import '../datasources/income_local_data_source.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  const IncomeRepositoryImpl(this._localDataSource);

  final IncomeLocalDataSource _localDataSource;

  @override
  Stream<List<Income>> watchIncomes() {
    return _localDataSource
        .watchIncomes()
        .map(
          (models) =>
              models.map((model) => model.toEntity()).toList(growable: false),
        )
        .handleError((Object _, StackTrace _) {
          throw const DatabaseFailure('Could not read your saved income.');
        });
  }

  @override
  Future<void> addIncome({
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) async {
    try {
      await _localDataSource.addIncome(
        amountCents: amountCents,
        categoryId: categoryId,
        note: note,
        date: date,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not save this income entry.');
    }
  }

  @override
  Future<void> deleteIncome(int id) async {
    try {
      await _localDataSource.deleteIncome(id);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not delete this income entry.');
    }
  }

  @override
  Future<void> updateIncome({
    required int id,
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) async {
    try {
      await _localDataSource.updateIncome(
        id: id,
        amountCents: amountCents,
        categoryId: categoryId,
        note: note,
        date: date,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not update this income entry.');
    }
  }

  @override
  Future<int?> amountCentsById(int id) async {
    try {
      return await _localDataSource.amountCentsById(id);
    } catch (_) {
      throw const DatabaseFailure('Could not read that income entry.');
    }
  }
}
