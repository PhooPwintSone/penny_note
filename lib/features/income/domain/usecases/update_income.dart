import '../../../../core/errors/app_failure.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../repositories/income_repository.dart';
import 'add_income.dart';

/// Validates and updates an existing income entry.
///
/// Income only increases Cash, but lowering an income entry can still make the
/// current Cash balance negative if that money has already been spent.
class UpdateIncome {
  const UpdateIncome(this._repository, this._accounts);

  final IncomeRepository _repository;
  final AccountRepository _accounts;

  Future<void> call({
    required int id,
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) async {
    if (id <= 0) {
      throw const ValidationFailure('That income entry could not be found.');
    }
    if (amountCents <= 0) {
      throw const ValidationFailure('Enter an amount greater than zero.');
    }
    if (categoryId <= 0) {
      throw const ValidationFailure('Choose an income category.');
    }
    final trimmedNote = note.trim();
    if (trimmedNote.length > AddIncome.maxNoteLength) {
      throw const ValidationFailure('Keep the note under 200 characters.');
    }

    final existingAmountCents = await _repository.amountCentsById(id);
    if (existingAmountCents == null) {
      throw const ValidationFailure('That income entry no longer exists.');
    }

    final summary = await _accounts.currentSummary();
    final projectedCashCents =
        summary.cashBalanceCents - existingAmountCents + amountCents;
    if (projectedCashCents < 0) {
      throw const ValidationFailure(
        'This change would make your Cash balance negative.',
      );
    }

    return _repository.updateIncome(
      id: id,
      amountCents: amountCents,
      categoryId: categoryId,
      note: trimmedNote,
      date: date,
    );
  }
}
