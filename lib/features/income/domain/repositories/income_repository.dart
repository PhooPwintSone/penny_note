import '../entities/income.dart';

/// Contract for income storage.
///
/// Implementations live in the data layer; the domain only knows about
/// [Income] objects and Dart streams/futures.
abstract interface class IncomeRepository {
  /// Emits every income entry, newest first, and re-emits after any write.
  Stream<List<Income>> watchIncomes();

  Future<void> addIncome({
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  });

  Future<void> updateIncome({
    required int id,
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  });

  Future<void> deleteIncome(int id);

  /// Returns the stored amount for validation before an edit or delete.
  Future<int?> amountCentsById(int id);
}
