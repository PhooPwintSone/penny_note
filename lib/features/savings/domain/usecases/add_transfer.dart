import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/money.dart';
import '../../../accounts/domain/entities/account_type.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../repositories/transfer_repository.dart';

/// Validates and records a transfer between Cash and Savings.
class AddTransfer {
  const AddTransfer(this._repository, this._accounts);

  static const maxNoteLength = 200;

  final TransferRepository _repository;
  final AccountRepository _accounts;

  Future<void> call({
    required int amountCents,
    required AccountType from,
    required AccountType to,
    required String note,
    required DateTime date,
    AppCurrency currency = AppCurrency.mmk,
  }) async {
    if (amountCents <= 0) {
      throw const ValidationFailure('Enter an amount greater than zero.');
    }
    if (from == to) {
      throw const ValidationFailure('Choose two different accounts.');
    }

    final trimmedNote = note.trim();
    if (trimmedNote.length > maxNoteLength) {
      throw const ValidationFailure('Keep the note under 200 characters.');
    }

    final fromAccount = await _accounts.accountByType(from);
    final toAccount = await _accounts.accountByType(to);
    final summary = await _accounts.currentSummary();
    final availableCents = summary.balanceFor(from);
    if (amountCents > availableCents) {
      throw ValidationFailure(
        'You only have ${formatCents(availableCents, currency)} available in '
        '${from.label}.',
      );
    }

    await _repository.addTransfer(
      amountCents: amountCents,
      from: fromAccount,
      to: toAccount,
      note: trimmedNote,
      date: date,
    );
  }
}
