import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/daos/category_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/datasources/category_local_data_source.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/watch_categories.dart';

final categoryDaoProvider = Provider<CategoryDao>((ref) {
  return ref.watch(appDatabaseProvider).categoryDao;
});

final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((
  ref,
) {
  return CategoryLocalDataSource(ref.watch(categoryDaoProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryLocalDataSourceProvider));
});

final watchCategoriesUseCaseProvider = Provider<WatchCategories>((ref) {
  return WatchCategories(ref.watch(categoryRepositoryProvider));
});

final addCategoryUseCaseProvider = Provider<AddCategory>((ref) {
  return AddCategory(ref.watch(categoryRepositoryProvider));
});

final updateCategoryUseCaseProvider = Provider<UpdateCategory>((ref) {
  return UpdateCategory(ref.watch(categoryRepositoryProvider));
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategory>((ref) {
  return DeleteCategory(ref.watch(categoryRepositoryProvider));
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(watchCategoriesUseCaseProvider)();
});
