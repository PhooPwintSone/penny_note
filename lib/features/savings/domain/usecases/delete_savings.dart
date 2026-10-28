import '../../../../core/errors/app_failure.dart';
import '../repositories/savings_repository.dart';

/// Removes a savings entry without letting a deposit deletion make the ledger
/// negative.
class DeleteSavings {
  const DeleteSavings(this._repository);

  final SavingsRepository _repository;

  Future<void> call(int id) async {
    if (id <= 0) {
      throw const ValidationFailure('That savings entry could not be found.');
    }

    final entry = await _repository.findById(id);
    if (entry == null) {
      throw const ValidationFailure('That savings entry no longer exists.');
    }

    if (!entry.isWithdrawal) {
      final total = await _repository.totalSavingsCents();
      if (total - entry.amountCents < 0) {
        throw const ValidationFailure(
          'This deposit is covering withdrawals. '
          'Delete a withdrawal first.',
        );
      }
    }

    await _repository.deleteSavings(id);
  }
}
