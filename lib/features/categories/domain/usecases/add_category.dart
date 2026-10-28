import '../../../../core/errors/app_failure.dart';
import '../repositories/category_repository.dart';

/// Validates and stores a new category.
class AddCategory {
  const AddCategory(this._repository);

  static const maxNameLength = 40;

  final CategoryRepository _repository;

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
    if (await _repository.categoryNameExists(trimmedName)) {
      throw const ValidationFailure(
        'A category with that name already exists.',
      );
    }

    await _repository.addCategory(name: trimmedName, icon: icon);
  }
}
