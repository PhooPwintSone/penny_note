import '../../../../core/errors/app_failure.dart';
import '../../../accounts/domain/entities/account_type.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../repositories/transfer_repository.dart';
import 'add_transfer.dart';

/// Validates and updates an existing transfer.
///
/// The original transfer is reversed before the new values are checked, so an
/// invalid edit never leaves either account with a negative balance and never
/// changes the stored row.
class UpdateTransfer {
  const UpdateTransfer(this._repository, this._accounts);

  final TransferRepository _repository;
  final AccountRepository _accounts;

  Future<void> call({
    required int id,
    required int amountCents,
    required AccountType from,
    required AccountType to,
    required String note,
    required DateTime date,
  }) async {
    if (id <= 0) {
      throw const ValidationFailure('That transfer could not be found.');
    }
    if (amountCents <= 0) {
      throw const ValidationFailure('Enter an amount greater than zero.');
    }
    if (from == to) {
      throw const ValidationFailure('Choose two different accounts.');
    }

    final trimmedNote = note.trim();
    if (trimmedNote.length > AddTransfer.maxNoteLength) {
      throw const ValidationFailure('Keep the note under 200 characters.');
    }

    final existing = await _repository.findById(id);
    if (existing == null) {
      throw const ValidationFailure('That transfer no longer exists.');
    }

    final fromAccount = await _accounts.accountByType(from);
    final toAccount = await _accounts.accountByType(to);
    final summary = await _accounts.currentSummary();

    var cashCents = summary.cashBalanceCents;
    var savingsCents = summary.savingsBalanceCents;

    // Reverse the original transfer first.
    if (existing.fromAccount.type == AccountType.cash) {
      cashCents += existing.amountCents;
      savingsCents -= existing.amountCents;
    } else {
      savingsCents += existing.amountCents;
      cashCents -= existing.amountCents;
    }

    // Apply the edited transfer.
    if (from == AccountType.cash) {
      cashCents -= amountCents;
      savingsCents += amountCents;
    } else {
      savingsCents -= amountCents;
      cashCents += amountCents;
    }

    if (cashCents < 0) {
      throw const ValidationFailure(
        'This change would make your Cash balance negative.',
      );
    }
    if (savingsCents < 0) {
      throw const ValidationFailure(
        'This change would make your Savings balance negative.',
      );
    }

    await _repository.updateTransfer(
      id: id,
      amountCents: amountCents,
      from: fromAccount,
      to: toAccount,
      note: trimmedNote,
      date: date,
    );
  }
}
