import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/daos/income_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/datasources/income_local_data_source.dart';
import '../../data/repositories/income_repository_impl.dart';
import '../../domain/entities/income.dart';
import '../../domain/repositories/income_repository.dart';
import '../../domain/usecases/add_income.dart';
import '../../domain/usecases/delete_income.dart';
import '../../domain/usecases/update_income.dart';
import '../../domain/usecases/watch_incomes.dart';

/// Dependency-injection graph for income entries.
///
/// This is the only layer that knows which concrete DAO, data source and
/// repository are used. ViewModels depend on use cases only.

final incomeDaoProvider = Provider<IncomeDao>((ref) {
  return ref.watch(appDatabaseProvider).incomeDao;
});

final incomeLocalDataSourceProvider = Provider<IncomeLocalDataSource>((ref) {
  return IncomeLocalDataSource(ref.watch(incomeDaoProvider));
});

final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  return IncomeRepositoryImpl(ref.watch(incomeLocalDataSourceProvider));
});

final watchIncomesUseCaseProvider = Provider<WatchIncomes>((ref) {
  return WatchIncomes(ref.watch(incomeRepositoryProvider));
});

final addIncomeUseCaseProvider = Provider<AddIncome>((ref) {
  return AddIncome(ref.watch(incomeRepositoryProvider));
});

final updateIncomeUseCaseProvider = Provider<UpdateIncome>((ref) {
  return UpdateIncome(ref.watch(incomeRepositoryProvider));
});

final deleteIncomeUseCaseProvider = Provider<DeleteIncome>((ref) {
  return DeleteIncome(ref.watch(incomeRepositoryProvider));
});

/// Live income entries from SQLite. Drift re-runs the query after every write.
final incomesStreamProvider = StreamProvider<List<Income>>((ref) {
  return ref.watch(watchIncomesUseCaseProvider)();
});
