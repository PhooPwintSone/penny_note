import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories.dart';
import '../tables/expenses.dart';

part 'expense_dao.g.dart';

/// A joined expense + category row, read in a single query.
///
/// Kept in the database layer so the repository can map it without exposing
/// Drift's `TypedResult` to the rest of the app.
class ExpenseWithCategoryRow {
  const ExpenseWithCategoryRow({required this.expense, required this.category});

  final ExpenseRow expense;
  final CategoryRow category;
}

@DriftAccessor(tables: [Expenses, Categories])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  ExpenseDao(super.db);

  Stream<List<ExpenseWithCategoryRow>> watchAll() {
    final query =
        select(expenses).join([
          innerJoin(categories, categories.id.equalsExp(expenses.categoryId)),
        ])..orderBy([
          OrderingTerm.desc(expenses.date),
          OrderingTerm.desc(expenses.id),
        ]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => ExpenseWithCategoryRow(
              expense: row.readTable(expenses),
              category: row.readTable(categories),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<int> insertExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  Future<bool> updateExpense(int id, ExpensesCompanion expense) async {
    final updated = await (update(
      expenses,
    )..where((row) => row.id.equals(id))).write(expense);
    return updated > 0;
  }

  Future<bool> deleteExpense(int id) async {
    final deleted = await (delete(
      expenses,
    )..where((row) => row.id.equals(id))).go();
    return deleted > 0;
  }

  Future<int?> amountCentsById(int id) async {
    final row = await (select(
      expenses,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    return row?.amountCents;
  }
}
