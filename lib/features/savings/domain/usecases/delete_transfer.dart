import '../../../../core/errors/app_failure.dart';
import '../../../accounts/domain/entities/account_type.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../repositories/transfer_repository.dart';

/// Removes a transfer after checking that reversing it cannot make either
/// account negative.
class DeleteTransfer {
  const DeleteTransfer(this._repository, this._accounts);

  final TransferRepository _repository;
  final AccountRepository _accounts;

  Future<void> call(int id) async {
    if (id <= 0) {
      throw const ValidationFailure('That transfer could not be found.');
    }

    final existing = await _repository.findById(id);
    if (existing == null) {
      throw const ValidationFailure('That transfer no longer exists.');
    }

    final summary = await _accounts.currentSummary();
    var cashCents = summary.cashBalanceCents;
    var savingsCents = summary.savingsBalanceCents;

    if (existing.fromAccount.type == AccountType.cash) {
      cashCents += existing.amountCents;
      savingsCents -= existing.amountCents;
    } else {
      savingsCents += existing.amountCents;
      cashCents -= existing.amountCents;
    }

    if (cashCents < 0) {
      throw const ValidationFailure(
        'This transfer is covering Cash spending. Delete or adjust those '
        'expenses first.',
      );
    }
    if (savingsCents < 0) {
      throw const ValidationFailure(
        'This transfer is covering Savings withdrawals. Delete or adjust '
        'those first.',
      );
    }

    await _repository.deleteTransfer(id);
  }
}
