import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._localDataSource);

  final CategoryLocalDataSource _localDataSource;

  @override
  Stream<List<Category>> watchCategories() {
    return _localDataSource
        .watchCategories()
        .map(
          (models) =>
              models.map((model) => model.toEntity()).toList(growable: false),
        )
        .handleError((Object _, StackTrace _) {
          throw const DatabaseFailure('Could not read your categories.');
        });
  }

  @override
  Future<void> addCategory({required String name, required String icon}) async {
    try {
      await _localDataSource.addCategory(name: name, icon: icon);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not add this category.');
    }
  }

  @override
  Future<void> updateCategory({
    required int id,
    required String name,
    required String icon,
  }) async {
    try {
      await _localDataSource.updateCategory(id: id, name: name, icon: icon);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not update this category.');
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await _localDataSource.deleteCategory(id);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not delete this category.');
    }
  }

  @override
  Future<bool> categoryNameExists(String name, {int? excludingId}) async {
    try {
      return await _localDataSource.categoryNameExists(
        name,
        excludingId: excludingId,
      );
    } catch (_) {
      throw const DatabaseFailure('Could not check that category name.');
    }
  }

  @override
  Future<int> countCategories() async {
    try {
      return await _localDataSource.countCategories();
    } catch (_) {
      throw const DatabaseFailure('Could not count your categories.');
    }
  }

  @override
  Future<int> countExpensesInCategory(int categoryId) async {
    try {
      return await _localDataSource.countExpensesInCategory(categoryId);
    } catch (_) {
      throw const DatabaseFailure('Could not check this category.');
    }
  }
}
