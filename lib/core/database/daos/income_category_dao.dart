import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/income_categories.dart';
import '../tables/incomes.dart';

part 'income_category_dao.g.dart';

@DriftAccessor(tables: [IncomeCategories, Incomes])
class IncomeCategoryDao extends DatabaseAccessor<AppDatabase>
    with _$IncomeCategoryDaoMixin {
  IncomeCategoryDao(super.db);

  Stream<List<IncomeCategoryRow>> watchAll() {
    final query = select(incomeCategories)
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
    return query.watch();
  }

  Future<int> insertCategory(IncomeCategoriesCompanion category) {
    return into(incomeCategories).insert(category);
  }

  Future<bool> updateCategory(
    int id,
    IncomeCategoriesCompanion category,
  ) async {
    final updated = await (update(
      incomeCategories,
    )..where((row) => row.id.equals(id))).write(category);
    return updated > 0;
  }

  Future<bool> deleteCategory(int id) async {
    final deleted = await (delete(
      incomeCategories,
    )..where((row) => row.id.equals(id))).go();
    return deleted > 0;
  }

  Future<bool> nameExists(String name, {int? excludingId}) async {
    final normalized = name.trim().toLowerCase();
    final query = select(incomeCategories)
      ..where((row) {
        final sameName = row.name.lower().equals(normalized);
        if (excludingId == null) return sameName;
        return sameName & row.id.equals(excludingId).not();
      })
      ..limit(1);
    return (await query.get()).isNotEmpty;
  }

  Future<int> countCategories() async {
    final count = incomeCategories.id.count();
    final query = selectOnly(incomeCategories)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> countIncomesForCategory(int categoryId) async {
    final count = incomes.id.count();
    final query = selectOnly(incomes)
      ..addColumns([count])
      ..where(incomes.categoryId.equals(categoryId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
