import '../entities/savings_entry.dart';

/// Contract for the local savings ledger.
abstract interface class SavingsRepository {
  /// Emits every savings entry, newest first, and re-emits after any write.
  Stream<List<SavingsEntry>> watchSavings();

  Future<void> addSavings({
    required int amountCents,
    required bool isWithdrawal,
    required String note,
    required DateTime date,
  });

  Future<void> deleteSavings(int id);

  Future<int> totalSavingsCents();

  Future<SavingsEntry?> findById(int id);
}
