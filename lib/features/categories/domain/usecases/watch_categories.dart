import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Returns a live list of categories, re-emitting when a category is added.
class WatchCategories {
  const WatchCategories(this._repository);

  final CategoryRepository _repository;

  Stream<List<Category>> call() => _repository.watchCategories();
}
