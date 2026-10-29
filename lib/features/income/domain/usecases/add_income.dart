import '../../../../core/errors/app_failure.dart';
import '../repositories/income_repository.dart';

/// Validates and stores a new income entry.
class AddIncome {
  const AddIncome(this._repository);

  static const maxNoteLength = 200;

  final IncomeRepository _repository;

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
      throw const ValidationFailure('Choose an income category.');
    }
    final trimmedNote = note.trim();
    if (trimmedNote.length > maxNoteLength) {
      throw const ValidationFailure('Keep the note under 200 characters.');
    }

    return _repository.addIncome(
      amountCents: amountCents,
      categoryId: categoryId,
      note: trimmedNote,
      date: date,
    );
  }
}
