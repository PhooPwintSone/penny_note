import '../../../../core/errors/app_failure.dart';
import '../repositories/income_repository.dart';

/// Removes an income entry by id.
class DeleteIncome {
  const DeleteIncome(this._repository);

  final IncomeRepository _repository;

  Future<void> call(int id) {
    if (id <= 0) {
      throw const ValidationFailure('That income entry could not be found.');
    }
    return _repository.deleteIncome(id);
  }
}
