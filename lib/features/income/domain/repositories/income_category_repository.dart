import '../entities/income_category.dart';

/// Contract for reading and customizing income categories.
///
/// The domain layer owns this interface; the data layer decides how it is
/// stored. Widgets must go through a use case, never a DAO.
abstract interface class IncomeCategoryRepository {
  Stream<List<IncomeCategory>> watchIncomeCategories();

  Future<void> addIncomeCategory({required String name, required String icon});

  Future<void> updateIncomeCategory({
    required int id,
    required String name,
    required String icon,
  });

  Future<void> deleteIncomeCategory(int id);

  Future<bool> incomeCategoryNameExists(String name, {int? excludingId});

  Future<int> countIncomeCategories();

  Future<int> countIncomesInCategory(int categoryId);
}
