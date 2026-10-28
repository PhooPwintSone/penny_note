import '../../../../core/errors/app_failure.dart';
import '../repositories/category_repository.dart';
import 'add_category.dart';

/// Validates and updates an existing category.
class UpdateCategory {
  const UpdateCategory(this._repository);

  final CategoryRepository _repository;

  Future<void> call({
    required int id,
    required String name,
    required String icon,
  }) async {
    if (id <= 0) {
      throw const ValidationFailure('That category could not be found.');
    }
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationFailure('Enter a category name.');
    }
    if (trimmedName.length > AddCategory.maxNameLength) {
      throw const ValidationFailure('Keep the name under 40 characters.');
    }
    if (icon.trim().isEmpty) {
      throw const ValidationFailure('Choose an icon.');
    }
    if (await _repository.categoryNameExists(trimmedName, excludingId: id)) {
      throw const ValidationFailure(
        'A category with that name already exists.',
      );
    }

    await _repository.updateCategory(id: id, name: trimmedName, icon: icon);
  }
}
