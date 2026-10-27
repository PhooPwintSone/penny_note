import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/daos/expense_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/datasources/expense_local_data_source.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/watch_expenses.dart';

/// Dependency-injection graph for the expenses feature.
///
/// This is the only layer that knows which concrete DAO, data source and
/// repository are used. ViewModels depend on use cases only.

final expenseDaoProvider = Provider<ExpenseDao>((ref) {
  return ref.watch(appDatabaseProvider).expenseDao;
});

final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  return ExpenseLocalDataSource(ref.watch(expenseDaoProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.watch(expenseLocalDataSourceProvider));
});

final watchExpensesUseCaseProvider = Provider<WatchExpenses>((ref) {
  return WatchExpenses(ref.watch(expenseRepositoryProvider));
});

final addExpenseUseCaseProvider = Provider<AddExpense>((ref) {
  return AddExpense(ref.watch(expenseRepositoryProvider));
});

final deleteExpenseUseCaseProvider = Provider<DeleteExpense>((ref) {
  return DeleteExpense(ref.watch(expenseRepositoryProvider));
});

/// Live expenses from SQLite. Drift re-runs the query after every write.
final expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(watchExpensesUseCaseProvider)();
});
