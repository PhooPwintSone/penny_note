import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/daos/savings_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/datasources/savings_local_data_source.dart';
import '../../data/repositories/savings_repository_impl.dart';
import '../../domain/entities/savings_entry.dart';
import '../../domain/repositories/savings_repository.dart';
import '../../domain/usecases/add_savings.dart';
import '../../domain/usecases/delete_savings.dart';
import '../../domain/usecases/watch_savings.dart';

final savingsDaoProvider = Provider<SavingsDao>((ref) {
  return ref.watch(appDatabaseProvider).savingsDao;
});

final savingsLocalDataSourceProvider = Provider<SavingsLocalDataSource>((ref) {
  return SavingsLocalDataSource(ref.watch(savingsDaoProvider));
});

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  return SavingsRepositoryImpl(ref.watch(savingsLocalDataSourceProvider));
});

final watchSavingsUseCaseProvider = Provider<WatchSavings>((ref) {
  return WatchSavings(ref.watch(savingsRepositoryProvider));
});

final addSavingsUseCaseProvider = Provider<AddSavings>((ref) {
  return AddSavings(ref.watch(savingsRepositoryProvider));
});

final deleteSavingsUseCaseProvider = Provider<DeleteSavings>((ref) {
  return DeleteSavings(ref.watch(savingsRepositoryProvider));
});

final savingsStreamProvider = StreamProvider<List<SavingsEntry>>((ref) {
  return ref.watch(watchSavingsUseCaseProvider)();
});
