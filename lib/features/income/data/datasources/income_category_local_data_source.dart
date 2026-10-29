import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/income_category_dao.dart';
import '../../../../core/errors/app_failure.dart';
import '../models/income_category_model.dart';

class IncomeCategoryLocalDataSource {
  const IncomeCategoryLocalDataSource(this._dao);

  final IncomeCategoryDao _dao;

  Stream<List<IncomeCategoryModel>> watchIncomeCategories() {
    return _dao.watchAll().map(
      (rows) => rows.map(IncomeCategoryModel.fromRow).toList(growable: false),
    );
  }

  Future<void> addIncomeCategory({
    required String name,
    required String icon,
  }) async {
    await _dao.insertCategory(
      IncomeCategoriesCompanion.insert(name: name, icon: icon),
    );
  }

  Future<void> updateIncomeCategory({
    required int id,
    required String name,
    required String icon,
  }) async {
    final updated = await _dao.updateCategory(
      id,
      IncomeCategoriesCompanion(name: Value(name), icon: Value(icon)),
    );
    if (!updated) {
      throw const DatabaseFailure('That income category no longer exists.');
    }
  }

  Future<void> deleteIncomeCategory(int id) async {
    final deleted = await _dao.deleteCategory(id);
    if (!deleted) {
      throw const DatabaseFailure('That income category no longer exists.');
    }
  }

  Future<bool> incomeCategoryNameExists(String name, {int? excludingId}) {
    return _dao.nameExists(name, excludingId: excludingId);
  }

  Future<int> countIncomeCategories() => _dao.countCategories();

  Future<int> countIncomesInCategory(int categoryId) {
    return _dao.countIncomesForCategory(categoryId);
  }
}
