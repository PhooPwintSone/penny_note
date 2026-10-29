import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/income_categories.dart';
import '../tables/incomes.dart';

part 'income_dao.g.dart';

/// A joined income + income-category row, read in a single query.
///
/// Kept in the database layer so the repository can map it without exposing
/// Drift's `TypedResult` to the rest of the app.
class IncomeWithCategoryRow {
  const IncomeWithCategoryRow({required this.income, required this.category});

  final IncomeRow income;
  final IncomeCategoryRow category;
}

@DriftAccessor(tables: [Incomes, IncomeCategories])
class IncomeDao extends DatabaseAccessor<AppDatabase> with _$IncomeDaoMixin {
  IncomeDao(super.db);

  Stream<List<IncomeWithCategoryRow>> watchAll() {
    final query =
        select(incomes).join([
          innerJoin(
            incomeCategories,
            incomeCategories.id.equalsExp(incomes.categoryId),
          ),
        ])..orderBy([
          OrderingTerm.desc(incomes.date),
          OrderingTerm.desc(incomes.id),
        ]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => IncomeWithCategoryRow(
              income: row.readTable(incomes),
              category: row.readTable(incomeCategories),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<int> insertIncome(IncomesCompanion income) {
    return into(incomes).insert(income);
  }

  Future<bool> updateIncome(int id, IncomesCompanion income) async {
    final updated = await (update(
      incomes,
    )..where((row) => row.id.equals(id))).write(income);
    return updated > 0;
  }

  Future<bool> deleteIncome(int id) async {
    final deleted = await (delete(
      incomes,
    )..where((row) => row.id.equals(id))).go();
    return deleted > 0;
  }

  Future<int?> amountCentsById(int id) async {
    final row = await (select(
      incomes,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    return row?.amountCents;
  }
}
