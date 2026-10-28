import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/database/app_database.dart';
import 'package:penny_note/core/errors/app_failure.dart';
import 'package:penny_note/features/categories/data/datasources/category_local_data_source.dart';
import 'package:penny_note/features/categories/data/repositories/category_repository_impl.dart';
import 'package:penny_note/features/categories/domain/repositories/category_repository.dart';
import 'package:penny_note/features/categories/domain/usecases/add_category.dart';
import 'package:penny_note/features/categories/domain/usecases/delete_category.dart';
import 'package:penny_note/features/categories/domain/usecases/update_category.dart';
import 'package:penny_note/features/expenses/data/datasources/expense_local_data_source.dart';

void main() {
  late AppDatabase database;
  late CategoryRepository repository;
  late AddCategory addCategory;
  late UpdateCategory updateCategory;
  late DeleteCategory deleteCategory;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CategoryRepositoryImpl(
      CategoryLocalDataSource(database.categoryDao),
    );
    addCategory = AddCategory(repository);
    updateCategory = UpdateCategory(repository);
    deleteCategory = DeleteCategory(repository);
  });

  tearDown(() => database.close());

  test('adds, renames, checks names, and deletes a category', () async {
    await addCategory(name: 'Gifts', icon: 'celebration');

    var categories = await repository.watchCategories().first;
    final coffee = categories.firstWhere((item) => item.name == 'Gifts');
    expect(coffee.icon, 'celebration');
    expect(await repository.categoryNameExists('gifts'), isTrue);

    await updateCategory(id: coffee.id, name: 'Presents', icon: 'celebration');

    categories = await repository.watchCategories().first;
    expect(categories.any((item) => item.name == 'Gifts'), isFalse);
    expect(
      categories.firstWhere((item) => item.id == coffee.id).name,
      'Presents',
    );

    await deleteCategory(coffee.id);
    categories = await repository.watchCategories().first;
    expect(categories.any((item) => item.id == coffee.id), isFalse);
  });

  test('rejects duplicate category names', () async {
    expect(
      () => addCategory(name: 'Food', icon: 'restaurant'),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('blocks deleting a category that is used by an expense', () async {
    final categories = await repository.watchCategories().first;
    final food = categories.firstWhere((item) => item.name == 'Food');
    final expenses = ExpenseLocalDataSource(database.expenseDao);
    await expenses.addExpense(
      amountCents: 500,
      categoryId: food.id,
      note: 'Lunch',
      date: DateTime(2026, 10, 27),
    );

    expect(() => deleteCategory(food.id), throwsA(isA<ValidationFailure>()));
  });

  test('keeps at least one category', () async {
    final categories = await repository.watchCategories().first;
    final food = categories.firstWhere((item) => item.name == 'Food');
    for (final category in categories) {
      if (category.id != food.id) {
        await database.categoryDao.deleteCategory(category.id);
      }
    }

    expect(() => deleteCategory(food.id), throwsA(isA<ValidationFailure>()));
  });
}
