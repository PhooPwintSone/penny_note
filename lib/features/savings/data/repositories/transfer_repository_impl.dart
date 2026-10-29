import '../../../../core/errors/app_failure.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../domain/entities/transfer.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_local_data_source.dart';

class TransferRepositoryImpl implements TransferRepository {
  const TransferRepositoryImpl(this._localDataSource);

  final TransferLocalDataSource _localDataSource;

  @override
  Stream<List<Transfer>> watchTransfers() {
    return _localDataSource
        .watchTransfers()
        .map(
          (models) =>
              models.map((model) => model.toEntity()).toList(growable: false),
        )
        .handleError((Object _, StackTrace _) {
          throw const DatabaseFailure('Could not read your transfers.');
        });
  }

  @override
  Future<void> addTransfer({
    required int amountCents,
    required Account from,
    required Account to,
    required String note,
    required DateTime date,
  }) async {
    try {
      await _localDataSource.addTransfer(
        amountCents: amountCents,
        from: from,
        to: to,
        note: note,
        date: date,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not save this transfer.');
    }
  }

  @override
  Future<void> updateTransfer({
    required int id,
    required int amountCents,
    required Account from,
    required Account to,
    required String note,
    required DateTime date,
  }) async {
    try {
      await _localDataSource.updateTransfer(
        id: id,
        amountCents: amountCents,
        from: from,
        to: to,
        note: note,
        date: date,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not update this transfer.');
    }
  }

  @override
  Future<void> deleteTransfer(int id) async {
    try {
      await _localDataSource.deleteTransfer(id);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not delete this transfer.');
    }
  }

  @override
  Future<Transfer?> findById(int id) async {
    try {
      final model = await _localDataSource.findById(id);
      return model?.toEntity();
    } catch (_) {
      throw const DatabaseFailure('Could not read that transfer.');
    }
  }
}
