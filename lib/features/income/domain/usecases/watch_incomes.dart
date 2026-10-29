import '../entities/income.dart';
import '../repositories/income_repository.dart';

/// Returns a live list of income entries, re-emitting after any write.
class WatchIncomes {
  const WatchIncomes(this._repository);

  final IncomeRepository _repository;

  Stream<List<Income>> call() => _repository.watchIncomes();
}
