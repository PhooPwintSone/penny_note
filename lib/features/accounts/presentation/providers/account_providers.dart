import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/daos/account_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/datasources/account_local_data_source.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/financial_summary.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/usecases/watch_financial_summary.dart';

/// Dependency-injection graph for the built-in accounts and balances.
final accountDaoProvider = Provider<AccountDao>((ref) {
  return ref.watch(appDatabaseProvider).accountDao;
});

final accountLocalDataSourceProvider = Provider<AccountLocalDataSource>((ref) {
  return AccountLocalDataSource(ref.watch(accountDaoProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(accountLocalDataSourceProvider));
});

final watchFinancialSummaryUseCaseProvider = Provider<WatchFinancialSummary>((
  ref,
) {
  return WatchFinancialSummary(ref.watch(accountRepositoryProvider));
});

/// Live balances from SQLite. Drift re-runs the aggregate query after every
/// income, expense, or transfer write.
final financialSummaryStreamProvider = StreamProvider<FinancialSummary>((ref) {
  return ref.watch(watchFinancialSummaryUseCaseProvider)();
});
