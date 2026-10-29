import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/daos/income_category_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/datasources/income_category_local_data_source.dart';
import '../../data/repositories/income_category_repository_impl.dart';
import '../../domain/entities/income_category.dart';
import '../../domain/repositories/income_category_repository.dart';
import '../../domain/usecases/add_income_category.dart';
import '../../domain/usecases/delete_income_category.dart';
import '../../domain/usecases/update_income_category.dart';
import '../../domain/usecases/watch_income_categories.dart';

final incomeCategoryDaoProvider = Provider<IncomeCategoryDao>((ref) {
  return ref.watch(appDatabaseProvider).incomeCategoryDao;
});

final incomeCategoryLocalDataSourceProvider =
    Provider<IncomeCategoryLocalDataSource>((ref) {
      return IncomeCategoryLocalDataSource(
        ref.watch(incomeCategoryDaoProvider),
      );
    });

final incomeCategoryRepositoryProvider = Provider<IncomeCategoryRepository>((
  ref,
) {
  return IncomeCategoryRepositoryImpl(
    ref.watch(incomeCategoryLocalDataSourceProvider),
  );
});

final watchIncomeCategoriesUseCaseProvider = Provider<WatchIncomeCategories>((
  ref,
) {
  return WatchIncomeCategories(ref.watch(incomeCategoryRepositoryProvider));
});

final addIncomeCategoryUseCaseProvider = Provider<AddIncomeCategory>((ref) {
  return AddIncomeCategory(ref.watch(incomeCategoryRepositoryProvider));
});

final updateIncomeCategoryUseCaseProvider = Provider<UpdateIncomeCategory>((
  ref,
) {
  return UpdateIncomeCategory(ref.watch(incomeCategoryRepositoryProvider));
});

final deleteIncomeCategoryUseCaseProvider = Provider<DeleteIncomeCategory>((
  ref,
) {
  return DeleteIncomeCategory(ref.watch(incomeCategoryRepositoryProvider));
});

final incomeCategoriesStreamProvider = StreamProvider<List<IncomeCategory>>((
  ref,
) {
  return ref.watch(watchIncomeCategoriesUseCaseProvider)();
});
