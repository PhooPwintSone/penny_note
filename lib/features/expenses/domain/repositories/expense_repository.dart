import '../entities/expense.dart';

/// Contract for expense storage.
///
/// Implementations live in the data layer; the domain only knows about
/// [Expense] objects and Dart streams/futures.
abstract interface class ExpenseRepository {
  /// Emits every expense, newest first, and re-emits after any write.
  Stream<List<Expense>> watchExpenses();

  Future<void> addExpense({
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  });

  Future<void> updateExpense({
    required int id,
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  });

  Future<void> deleteExpense(int id);

  /// Returns the stored amount for validation before an edit or delete.
  Future<int?> amountCentsById(int id);
}
