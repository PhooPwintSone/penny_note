import '../entities/income_category.dart';
import '../repositories/income_category_repository.dart';

/// Returns a live list of income categories.
class WatchIncomeCategories {
  const WatchIncomeCategories(this._repository);

  final IncomeCategoryRepository _repository;

  Stream<List<IncomeCategory>> call() => _repository.watchIncomeCategories();
}
