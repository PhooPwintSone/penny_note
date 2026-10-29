import '../../../../core/errors/app_failure.dart';
import '../repositories/income_repository.dart';
import 'add_income.dart';

/// Validates and updates an existing income entry.
class UpdateIncome {
  const UpdateIncome(this._repository);

  final IncomeRepository _repository;

  Future<void> call({
    required int id,
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) {
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

    return _repository.updateIncome(
      id: id,
      amountCents: amountCents,
      categoryId: categoryId,
      note: trimmedNote,
      date: date,
    );
  }
}
