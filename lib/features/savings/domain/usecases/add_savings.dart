import '../../../../core/errors/app_failure.dart';
import '../repositories/savings_repository.dart';

/// Validates and records money added to or taken out of savings.
class AddSavings {
  const AddSavings(this._repository);

  static const maxNoteLength = 200;

  final SavingsRepository _repository;

  Future<void> call({
    required int amountCents,
    required bool isWithdrawal,
    required String note,
    required DateTime date,
  }) async {
    if (amountCents <= 0) {
      throw const ValidationFailure('Enter an amount greater than zero.');
    }
    final trimmedNote = note.trim();
    if (trimmedNote.length > maxNoteLength) {
      throw const ValidationFailure('Keep the note under 200 characters.');
    }

    if (isWithdrawal) {
      final total = await _repository.totalSavingsCents();
      if (amountCents > total) {
        throw const ValidationFailure(
          'You cannot withdraw more than your current savings.',
        );
      }
    }

    await _repository.addSavings(
      amountCents: amountCents,
      isWithdrawal: isWithdrawal,
      note: trimmedNote,
      date: date,
    );
  }
}
