import '../../../../core/errors/app_failure.dart';
import '../repositories/expense_repository.dart';

/// Removes an expense by id.
class DeleteExpense {
  const DeleteExpense(this._repository);

  final ExpenseRepository _repository;

  Future<void> call(int id) {
    if (id <= 0) {
      throw const ValidationFailure('That expense could not be found.');
    }
    return _repository.deleteExpense(id);
  }
}
