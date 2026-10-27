import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Returns a live list of all expenses, newest first.
class WatchExpenses {
  const WatchExpenses(this._repository);

  final ExpenseRepository _repository;

  Stream<List<Expense>> call() => _repository.watchExpenses();
}
