import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/database/app_database.dart';
import 'package:penny_note/core/errors/app_failure.dart';
import 'package:penny_note/features/income/data/datasources/income_category_local_data_source.dart';
import 'package:penny_note/features/income/data/datasources/income_local_data_source.dart';
import 'package:penny_note/features/income/data/repositories/income_category_repository_impl.dart';
import 'package:penny_note/features/income/data/repositories/income_repository_impl.dart';
import 'package:penny_note/features/income/domain/repositories/income_category_repository.dart';
import 'package:penny_note/features/income/domain/repositories/income_repository.dart';
import 'package:penny_note/features/income/domain/usecases/add_income.dart';
import 'package:penny_note/features/income/domain/usecases/add_income_category.dart';
import 'package:penny_note/features/income/domain/usecases/delete_income.dart';
import 'package:penny_note/features/income/domain/usecases/delete_income_category.dart';
import 'package:penny_note/features/income/domain/usecases/update_income.dart';
import 'package:penny_note/features/income/domain/usecases/update_income_category.dart';

void main() {
  late AppDatabase database;
  late IncomeRepository incomeRepository;
  late IncomeCategoryRepository categoryRepository;
  late AddIncome addIncome;
  late UpdateIncome updateIncome;
  late DeleteIncome deleteIncome;
  late AddIncomeCategory addIncomeCategory;
  late UpdateIncomeCategory updateIncomeCategory;
  late DeleteIncomeCategory deleteIncomeCategory;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    incomeRepository = IncomeRepositoryImpl(
      IncomeLocalDataSource(database.incomeDao),
    );
    categoryRepository = IncomeCategoryRepositoryImpl(
      IncomeCategoryLocalDataSource(database.incomeCategoryDao),
    );
    addIncome = AddIncome(incomeRepository);
    updateIncome = UpdateIncome(incomeRepository);
    deleteIncome = DeleteIncome(incomeRepository);
    addIncomeCategory = AddIncomeCategory(categoryRepository);
    updateIncomeCategory = UpdateIncomeCategory(categoryRepository);
    deleteIncomeCategory = DeleteIncomeCategory(categoryRepository);
  });

  tearDown(() => database.close());

  test('adds, updates, and deletes an income entry', () async {
    final categories = await categoryRepository.watchIncomeCategories().first;
    final salary = categories.firstWhere((item) => item.name == 'Salary');
    final freelance = categories.firstWhere((item) => item.name == 'Freelance');

    await addIncome(
      amountCents: 250000,
      categoryId: salary.id,
      note: '  October salary  ',
      date: DateTime(2026, 10, 27),
    );

    var incomes = await incomeRepository.watchIncomes().first;
    expect(incomes, hasLength(1));
    expect(incomes.single.amountCents, 250000);
    expect(incomes.single.category.name, 'Salary');
    expect(incomes.single.note, 'October salary');

    final id = incomes.single.id;
    await updateIncome(
      id: id,
      amountCents: 300000,
      categoryId: freelance.id,
      note: 'Project payment',
      date: DateTime(2026, 10, 28),
    );

    incomes = await incomeRepository.watchIncomes().first;
    expect(incomes.single.amountCents, 300000);
    expect(incomes.single.category.name, 'Freelance');
    expect(incomes.single.note, 'Project payment');

    await deleteIncome(id);
    expect(await incomeRepository.watchIncomes().first, isEmpty);
  });

  test('validates income amounts and categories', () async {
    final categories = await categoryRepository.watchIncomeCategories().first;
    final salary = categories.firstWhere((item) => item.name == 'Salary');

    expect(
      () => addIncome(
        amountCents: 0,
        categoryId: salary.id,
        note: '',
        date: DateTime(2026, 10, 27),
      ),
      throwsA(isA<ValidationFailure>()),
    );
    expect(
      () => addIncome(
        amountCents: 100,
        categoryId: 0,
        note: '',
        date: DateTime(2026, 10, 27),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('adds, renames, checks names, and deletes an income category', () async {
    await addIncomeCategory(name: 'Bonus', icon: 'celebration');

    var categories = await categoryRepository.watchIncomeCategories().first;
    final bonus = categories.firstWhere((item) => item.name == 'Bonus');
    expect(bonus.icon, 'celebration');
    expect(await categoryRepository.incomeCategoryNameExists('bonus'), isTrue);

    await updateIncomeCategory(
      id: bonus.id,
      name: 'Annual bonus',
      icon: 'payments',
    );

    categories = await categoryRepository.watchIncomeCategories().first;
    expect(categories.any((item) => item.name == 'Bonus'), isFalse);
    expect(
      categories.firstWhere((item) => item.id == bonus.id).name,
      'Annual bonus',
    );

    await deleteIncomeCategory(bonus.id);
    categories = await categoryRepository.watchIncomeCategories().first;
    expect(categories.any((item) => item.id == bonus.id), isFalse);
  });

  test('rejects duplicate income category names', () async {
    expect(
      () => addIncomeCategory(name: 'Salary', icon: 'payments'),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('blocks deleting an income category used by an income entry', () async {
    final categories = await categoryRepository.watchIncomeCategories().first;
    final salary = categories.firstWhere((item) => item.name == 'Salary');
    await addIncome(
      amountCents: 500,
      categoryId: salary.id,
      note: 'Pay',
      date: DateTime(2026, 10, 27),
    );

    expect(
      () => deleteIncomeCategory(salary.id),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('keeps at least one income category', () async {
    final categories = await categoryRepository.watchIncomeCategories().first;
    final salary = categories.firstWhere((item) => item.name == 'Salary');
    for (final category in categories) {
      if (category.id != salary.id) {
        await database.incomeCategoryDao.deleteCategory(category.id);
      }
    }

    expect(
      () => deleteIncomeCategory(salary.id),
      throwsA(isA<ValidationFailure>()),
    );
  });
}
