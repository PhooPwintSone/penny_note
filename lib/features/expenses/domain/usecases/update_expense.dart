import '../../../../core/errors/app_failure.dart';
import '../repositories/expense_repository.dart';
import 'add_expense.dart';

/// Validates and updates an existing expense.
class UpdateExpense {
  const UpdateExpense(this._repository);

  final ExpenseRepository _repository;

  Future<void> call({
    required int id,
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) {
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

    return _repository.updateExpense(
      id: id,
      amountCents: amountCents,
      categoryId: categoryId,
      note: trimmedNote,
      date: date,
    );
  }
}
