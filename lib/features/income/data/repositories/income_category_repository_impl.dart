import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/income_category.dart';
import '../../domain/repositories/income_category_repository.dart';
import '../datasources/income_category_local_data_source.dart';

class IncomeCategoryRepositoryImpl implements IncomeCategoryRepository {
  const IncomeCategoryRepositoryImpl(this._localDataSource);

  final IncomeCategoryLocalDataSource _localDataSource;

  @override
  Stream<List<IncomeCategory>> watchIncomeCategories() {
    return _localDataSource
        .watchIncomeCategories()
        .map(
          (models) =>
              models.map((model) => model.toEntity()).toList(growable: false),
        )
        .handleError((Object _, StackTrace _) {
          throw const DatabaseFailure('Could not read your income categories.');
        });
  }

  @override
  Future<void> addIncomeCategory({
    required String name,
    required String icon,
  }) async {
    try {
      await _localDataSource.addIncomeCategory(name: name, icon: icon);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not add this income category.');
    }
  }

  @override
  Future<void> updateIncomeCategory({
    required int id,
    required String name,
    required String icon,
  }) async {
    try {
      await _localDataSource.updateIncomeCategory(
        id: id,
        name: name,
        icon: icon,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not update this income category.');
    }
  }

  @override
  Future<void> deleteIncomeCategory(int id) async {
    try {
      await _localDataSource.deleteIncomeCategory(id);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not delete this income category.');
    }
  }

  @override
  Future<bool> incomeCategoryNameExists(String name, {int? excludingId}) async {
    try {
      return await _localDataSource.incomeCategoryNameExists(
        name,
        excludingId: excludingId,
      );
    } catch (_) {
      throw const DatabaseFailure('Could not check that income category name.');
    }
  }

  @override
  Future<int> countIncomeCategories() async {
    try {
      return await _localDataSource.countIncomeCategories();
    } catch (_) {
      throw const DatabaseFailure('Could not count your income categories.');
    }
  }

  @override
  Future<int> countIncomesInCategory(int categoryId) async {
    try {
      return await _localDataSource.countIncomesInCategory(categoryId);
    } catch (_) {
      throw const DatabaseFailure('Could not check this income category.');
    }
  }
}
