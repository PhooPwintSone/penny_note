import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/money.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../repositories/expense_repository.dart';

/// Validates and stores a new expense.
///
/// Validation lives here (not in the widget) so every entry point, including
/// future imports or quick-add flows, obeys the same rules. Expenses can only
/// spend money that is actually available in Cash.
class AddExpense {
  const AddExpense(this._repository, this._accounts);

  static const maxNoteLength = 200;

  final ExpenseRepository _repository;
  final AccountRepository _accounts;

  Future<void> call({
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
    AppCurrency currency = AppCurrency.mmk,
  }) async {
    if (amountCents <= 0) {
      throw const ValidationFailure('Enter an amount greater than zero.');
    }
    if (categoryId <= 0) {
      throw const ValidationFailure('Choose a category.');
    }
    final trimmedNote = note.trim();
    if (trimmedNote.length > maxNoteLength) {
      throw const ValidationFailure('Keep the note under 200 characters.');
    }

    final summary = await _accounts.currentSummary();
    if (amountCents > summary.cashBalanceCents) {
      throw ValidationFailure(
        'You only have '
        '${formatCents(summary.cashBalanceCents, currency)} available in Cash.',
      );
    }

    return _repository.addExpense(
      amountCents: amountCents,
      categoryId: categoryId,
      note: trimmedNote,
      date: date,
    );
  }
}
