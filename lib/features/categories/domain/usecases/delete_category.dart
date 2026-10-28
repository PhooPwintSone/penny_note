import '../../../../core/errors/app_failure.dart';
import '../repositories/category_repository.dart';

/// Deletes an unused category.
///
/// Categories referenced by expenses are protected so existing entries keep
/// their history. The last remaining category is also protected because the
/// expense form needs at least one choice.
class DeleteCategory {
  const DeleteCategory(this._repository);

  final CategoryRepository _repository;

  Future<void> call(int id) async {
    if (id <= 0) {
      throw const ValidationFailure('That category could not be found.');
    }
    if (await _repository.countExpensesInCategory(id) > 0) {
      throw const ValidationFailure(
        'This category is used by existing expenses. '
        'Move or delete those expenses first.',
      );
    }
    if (await _repository.countCategories() <= 1) {
      throw const ValidationFailure('Keep at least one category.');
    }

    await _repository.deleteCategory(id);
  }
}
