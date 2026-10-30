import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/money.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../repositories/expense_repository.dart';
import 'add_expense.dart';

/// Validates and updates an existing expense.
///
/// The original expense is added back to the available Cash before the new
/// amount is checked, so editing an expense never counts it twice.
class UpdateExpense {
  const UpdateExpense(this._repository, this._accounts);

  final ExpenseRepository _repository;
  final AccountRepository _accounts;

  Future<void> call({
    required int id,
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
    AppCurrency currency = AppCurrency.mmk,
  }) async {
    if (id <= 0) {
      throw const ValidationFailure('That expense could not be found.');
    }
    if (amountCents <= 0) {
      throw const ValidationFailure('Enter an amount greater than zero.');
    }
    if (categoryId <= 0) {
      throw const ValidationFailure('Choose a category.');
    }
    final trimmedNote = note.trim();
    if (trimmedNote.length > AddExpense.maxNoteLength) {
      throw const ValidationFailure('Keep the note under 200 characters.');
    }

    final existingAmountCents = await _repository.amountCentsById(id);
    if (existingAmountCents == null) {
      throw const ValidationFailure('That expense no longer exists.');
    }

    final summary = await _accounts.currentSummary();
    final availableCents = summary.cashBalanceCents + existingAmountCents;
    if (amountCents > availableCents) {
      throw ValidationFailure(
        'This expense is more than your available Cash '
        '(${formatCents(availableCents, currency)}).',
      );
    }

    return _repository.updateExpense(
      id: id,
      amountCents: amountCents,
      categoryId: categoryId,
      note: trimmedNote,
      date: date,
    );
  }
}
