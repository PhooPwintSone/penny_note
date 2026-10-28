import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/category_dao.dart';
import '../../../../core/errors/app_failure.dart';
import '../models/category_model.dart';

class CategoryLocalDataSource {
  const CategoryLocalDataSource(this._dao);

  final CategoryDao _dao;

  Stream<List<CategoryModel>> watchCategories() {
    return _dao.watchAll().map(
      (rows) => rows.map(CategoryModel.fromRow).toList(growable: false),
    );
  }

  Future<void> addCategory({required String name, required String icon}) async {
    await _dao.insertCategory(
      CategoriesCompanion.insert(name: name, icon: icon),
    );
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    required String icon,
  }) async {
    final updated = await _dao.updateCategory(
      id,
      CategoriesCompanion(name: Value(name), icon: Value(icon)),
    );
    if (!updated) {
      throw const DatabaseFailure('That category no longer exists.');
    }
  }

  Future<void> deleteCategory(int id) async {
    final deleted = await _dao.deleteCategory(id);
    if (!deleted) {
      throw const DatabaseFailure('That category no longer exists.');
    }
  }

  Future<bool> categoryNameExists(String name, {int? excludingId}) {
    return _dao.nameExists(name, excludingId: excludingId);
  }

  Future<int> countCategories() => _dao.countCategories();

  Future<int> countExpensesInCategory(int categoryId) {
    return _dao.countExpensesForCategory(categoryId);
  }
}
