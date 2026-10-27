import '../../../../core/errors/app_failure.dart';
import '../repositories/expense_repository.dart';

/// Validates and stores a new expense.
///
/// Validation lives here (not in the widget) so every entry point, including
/// future imports or quick-add flows, obeys the same rules.
class AddExpense {
  const AddExpense(this._repository);

  static const maxNoteLength = 200;

  final ExpenseRepository _repository;

  Future<void> call({
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) {
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

    return _repository.addExpense(
      amountCents: amountCents,
      categoryId: categoryId,
      note: trimmedNote,
      date: date,
    );
  }
}
