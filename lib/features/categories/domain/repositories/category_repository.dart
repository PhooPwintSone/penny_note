import '../entities/category.dart';

/// Contract for reading categories.
///
/// The domain layer owns this interface; the data layer decides how it is
/// stored. Widgets must go through a use case, never a DAO.
abstract interface class CategoryRepository {
  Stream<List<Category>> watchCategories();
}
