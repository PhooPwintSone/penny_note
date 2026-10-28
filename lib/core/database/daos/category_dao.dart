import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories.dart';
import '../tables/expenses.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories, Expenses])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Stream<List<CategoryRow>> watchAll() {
    final query = select(categories)
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
    return query.watch();
  }

  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  Future<bool> updateCategory(int id, CategoriesCompanion category) async {
    final updated = await (update(
      categories,
    )..where((row) => row.id.equals(id))).write(category);
    return updated > 0;
  }

  Future<bool> deleteCategory(int id) async {
    final deleted = await (delete(
      categories,
    )..where((row) => row.id.equals(id))).go();
    return deleted > 0;
  }

  Future<bool> nameExists(String name, {int? excludingId}) async {
    final normalized = name.trim().toLowerCase();
    final query = select(categories)
      ..where((row) {
        final sameName = row.name.lower().equals(normalized);
        if (excludingId == null) return sameName;
        return sameName & row.id.equals(excludingId).not();
      })
      ..limit(1);
    return (await query.get()).isNotEmpty;
  }

  Future<int> countCategories() async {
    final count = categories.id.count();
    final query = selectOnly(categories)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> countExpensesForCategory(int categoryId) async {
    final count = expenses.id.count();
    final query = selectOnly(expenses)
      ..addColumns([count])
      ..where(expenses.categoryId.equals(categoryId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
