import '../../../../core/errors/app_failure.dart';
import '../repositories/income_category_repository.dart';
import 'add_income_category.dart';

/// Validates and updates an existing income category.
class UpdateIncomeCategory {
  const UpdateIncomeCategory(this._repository);

  final IncomeCategoryRepository _repository;

  Future<void> call({
    required int id,
    required String name,
    required String icon,
  }) async {
    if (id <= 0) {
      throw const ValidationFailure('That income category could not be found.');
    }
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationFailure('Enter a category name.');
    }
    if (trimmedName.length > AddIncomeCategory.maxNameLength) {
      throw const ValidationFailure('Keep the name under 40 characters.');
    }
    if (icon.trim().isEmpty) {
      throw const ValidationFailure('Choose an icon.');
    }
    if (await _repository.incomeCategoryNameExists(
      trimmedName,
      excludingId: id,
    )) {
      throw const ValidationFailure(
        'An income category with that name already exists.',
      );
    }

    await _repository.updateIncomeCategory(
      id: id,
      name: trimmedName,
      icon: icon,
    );
  }
}
