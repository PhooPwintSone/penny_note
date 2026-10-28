import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/savings_entry.dart';
import '../../domain/repositories/savings_repository.dart';
import '../datasources/savings_local_data_source.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  const SavingsRepositoryImpl(this._localDataSource);

  final SavingsLocalDataSource _localDataSource;

  @override
  Stream<List<SavingsEntry>> watchSavings() {
    return _localDataSource
        .watchSavings()
        .map(
          (models) =>
              models.map((model) => model.toEntity()).toList(growable: false),
        )
        .handleError((Object _, StackTrace _) {
          throw const DatabaseFailure('Could not read your savings.');
        });
  }

  @override
  Future<void> addSavings({
    required int amountCents,
    required bool isWithdrawal,
    required String note,
    required DateTime date,
  }) async {
    try {
      await _localDataSource.addSavings(
        amountCents: amountCents,
        isWithdrawal: isWithdrawal,
        note: note,
        date: date,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not save this savings entry.');
    }
  }

  @override
  Future<void> deleteSavings(int id) async {
    try {
      await _localDataSource.deleteSavings(id);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not delete this savings entry.');
    }
  }

  @override
  Future<int> totalSavingsCents() async {
    try {
      return await _localDataSource.totalSavingsCents();
    } catch (_) {
      throw const DatabaseFailure('Could not read your savings balance.');
    }
  }

  @override
  Future<SavingsEntry?> findById(int id) async {
    try {
      final model = await _localDataSource.findById(id);
      return model?.toEntity();
    } catch (_) {
      throw const DatabaseFailure('Could not read that savings entry.');
    }
  }
}
