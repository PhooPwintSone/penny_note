import '../../../../core/errors/app_failure.dart';
import '../repositories/income_category_repository.dart';

/// Validates and stores a new income category.
class AddIncomeCategory {
  const AddIncomeCategory(this._repository);

  static const maxNameLength = 40;

  final IncomeCategoryRepository _repository;

  Future<void> call({required String name, required String icon}) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationFailure('Enter a category name.');
    }
    if (trimmedName.length > maxNameLength) {
      throw const ValidationFailure('Keep the name under 40 characters.');
    }
    if (icon.trim().isEmpty) {
      throw const ValidationFailure('Choose an icon.');
    }
    if (await _repository.incomeCategoryNameExists(trimmedName)) {
      throw const ValidationFailure(
        'An income category with that name already exists.',
      );
    }

    await _repository.addIncomeCategory(name: trimmedName, icon: icon);
  }
}
