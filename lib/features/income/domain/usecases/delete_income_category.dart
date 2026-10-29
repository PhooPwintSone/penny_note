import '../../../../core/errors/app_failure.dart';
import '../repositories/income_category_repository.dart';

/// Deletes an unused income category.
///
/// Categories referenced by income entries are protected so existing entries
/// keep their history. The last remaining category is also protected because
/// the income form needs at least one choice.
class DeleteIncomeCategory {
  const DeleteIncomeCategory(this._repository);

  final IncomeCategoryRepository _repository;

  Future<void> call(int id) async {
    if (id <= 0) {
      throw const ValidationFailure('That income category could not be found.');
    }
    if (await _repository.countIncomesInCategory(id) > 0) {
      throw const ValidationFailure(
        'This category is used by existing income entries. '
        'Move or delete those entries first.',
      );
    }
    if (await _repository.countIncomeCategories() <= 1) {
      throw const ValidationFailure('Keep at least one income category.');
    }

    await _repository.deleteIncomeCategory(id);
  }
}
