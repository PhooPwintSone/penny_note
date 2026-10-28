import '../entities/category.dart';

/// Contract for reading and customizing categories.
///
/// The domain layer owns this interface; the data layer decides how it is
/// stored. Widgets must go through a use case, never a DAO.
abstract interface class CategoryRepository {
  Stream<List<Category>> watchCategories();

  Future<void> addCategory({required String name, required String icon});

  Future<void> updateCategory({
    required int id,
    required String name,
    required String icon,
  });

  Future<void> deleteCategory(int id);

  Future<bool> categoryNameExists(String name, {int? excludingId});

  Future<int> countCategories();

  Future<int> countExpensesInCategory(int categoryId);
}
