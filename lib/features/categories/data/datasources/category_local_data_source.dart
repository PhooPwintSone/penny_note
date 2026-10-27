import '../../../../core/database/daos/category_dao.dart';
import '../models/category_model.dart';

class CategoryLocalDataSource {
  const CategoryLocalDataSource(this._dao);

  final CategoryDao _dao;

  Stream<List<CategoryModel>> watchCategories() {
    return _dao.watchAll().map(
      (rows) => rows.map(CategoryModel.fromRow).toList(growable: false),
    );
  }
}
