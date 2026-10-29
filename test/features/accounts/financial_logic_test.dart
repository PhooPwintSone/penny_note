import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/database/app_database.dart';
import 'package:penny_note/core/errors/app_failure.dart';
import 'package:penny_note/features/accounts/data/datasources/account_local_data_source.dart';
import 'package:penny_note/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:penny_note/features/accounts/domain/entities/account_type.dart';
import 'package:penny_note/features/accounts/domain/entities/financial_summary.dart';
import 'package:penny_note/features/accounts/domain/repositories/account_repository.dart';
import 'package:penny_note/features/expenses/data/datasources/expense_local_data_source.dart';
import 'package:penny_note/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:penny_note/features/expenses/domain/repositories/expense_repository.dart';
import 'package:penny_note/features/expenses/domain/usecases/add_expense.dart';
import 'package:penny_note/features/expenses/domain/usecases/delete_expense.dart';
import 'package:penny_note/features/expenses/domain/usecases/update_expense.dart';
import 'package:penny_note/features/income/data/datasources/income_local_data_source.dart';
import 'package:penny_note/features/income/data/repositories/income_repository_impl.dart';
import 'package:penny_note/features/income/domain/repositories/income_repository.dart';
import 'package:penny_note/features/income/domain/usecases/add_income.dart';
import 'package:penny_note/features/income/domain/usecases/delete_income.dart';
import 'package:penny_note/features/income/domain/usecases/update_income.dart';
import 'package:penny_note/features/savings/data/datasources/transfer_local_data_source.dart';
import 'package:penny_note/features/savings/data/repositories/transfer_repository_impl.dart';
import 'package:penny_note/features/savings/domain/repositories/transfer_repository.dart';
import 'package:penny_note/features/savings/domain/usecases/add_transfer.dart';
import 'package:penny_note/features/savings/domain/usecases/delete_transfer.dart';
import 'package:penny_note/features/savings/domain/usecases/update_transfer.dart';

void main() {
  late AppDatabase database;
  late AccountRepository accountRepository;
  late ExpenseRepository expenseRepository;
  late IncomeRepository incomeRepository;
  late TransferRepository transferRepository;
  late AddExpense addExpense;
  late UpdateExpense updateExpense;
  late DeleteExpense deleteExpense;
  late AddIncome addIncome;
  late UpdateIncome updateIncome;
  late DeleteIncome deleteIncome;
  late AddTransfer addTransfer;
  late UpdateTransfer updateTransfer;
  late DeleteTransfer deleteTransfer;
  late int foodCategoryId;
  late int salaryCategoryId;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    accountRepository = AccountRepositoryImpl(
      AccountLocalDataSource(database.accountDao),
    );
    expenseRepository = ExpenseRepositoryImpl(
      ExpenseLocalDataSource(database.expenseDao),
    );
    incomeRepository = IncomeRepositoryImpl(
      IncomeLocalDataSource(database.incomeDao),
    );
    transferRepository = TransferRepositoryImpl(
      TransferLocalDataSource(database.transferDao),
    );
    addExpense = AddExpense(expenseRepository, accountRepository);
    updateExpense = UpdateExpense(expenseRepository, accountRepository);
    deleteExpense = DeleteExpense(expenseRepository);
    addIncome = AddIncome(incomeRepository);
    updateIncome = UpdateIncome(incomeRepository, accountRepository);
    deleteIncome = DeleteIncome(incomeRepository, accountRepository);
    addTransfer = AddTransfer(transferRepository, accountRepository);
    updateTransfer = UpdateTransfer(transferRepository, accountRepository);
    deleteTransfer = DeleteTransfer(transferRepository, accountRepository);

    final expenseCategories = await database.categoryDao.watchAll().first;
    foodCategoryId = expenseCategories
        .firstWhere((category) => category.name == 'Food')
        .id;
    final incomeCategories = await database.incomeCategoryDao.watchAll().first;
    salaryCategoryId = incomeCategories
        .firstWhere((category) => category.name == 'Salary')
        .id;
  });

  tearDown(() => database.close());

  Future<void> addIncomeCents(int amountCents) {
    return addIncome(
      amountCents: amountCents,
      categoryId: salaryCategoryId,
      note: 'Income',
      date: DateTime(2026, 10, 1),
    );
  }

  Future<void> addExpenseCents(int amountCents) {
    return addExpense(
      amountCents: amountCents,
      categoryId: foodCategoryId,
      note: 'Expense',
      date: DateTime(2026, 10, 1),
    );
  }

  Future<FinancialSummary> summary() => accountRepository.currentSummary();

  test('income increases Cash and is included in income totals', () async {
    await addIncomeCents(10000);

    final result = await summary();
    expect(result.cashBalanceCents, 10000);
    expect(result.savingsBalanceCents, 0);
    expect(result.totalIncomeCents, 10000);
    expect(result.totalExpenseCents, 0);
    expect(result.totalBalanceCents, 10000);
  });

  test('expense decreases Cash and is included in expense totals', () async {
    await addIncomeCents(10000);
    await addExpenseCents(3000);

    final result = await summary();
    expect(result.cashBalanceCents, 7000);
    expect(result.savingsBalanceCents, 0);
    expect(result.totalIncomeCents, 10000);
    expect(result.totalExpenseCents, 3000);
  });

  test(
    'Cash to Savings transfer moves money without changing the total',
    () async {
      await addIncomeCents(10000);
      final before = await summary();

      await addTransfer(
        amountCents: 2000,
        from: AccountType.cash,
        to: AccountType.savings,
        note: 'Save',
        date: DateTime(2026, 10, 2),
      );

      final after = await summary();
      expect(after.cashBalanceCents, 8000);
      expect(after.savingsBalanceCents, 2000);
      expect(after.totalBalanceCents, before.totalBalanceCents);
    },
  );

  test('Savings to Cash transfer moves money back', () async {
    await addIncomeCents(10000);
    await addTransfer(
      amountCents: 2000,
      from: AccountType.cash,
      to: AccountType.savings,
      note: 'Save',
      date: DateTime(2026, 10, 2),
    );

    await addTransfer(
      amountCents: 500,
      from: AccountType.savings,
      to: AccountType.cash,
      note: 'Withdraw',
      date: DateTime(2026, 10, 3),
    );

    final result = await summary();
    expect(result.cashBalanceCents, 8500);
    expect(result.savingsBalanceCents, 1500);
  });

  test('transfers never appear in income or expense reports', () async {
    await addIncomeCents(10000);
    await addExpenseCents(3000);
    await addTransfer(
      amountCents: 2000,
      from: AccountType.cash,
      to: AccountType.savings,
      note: 'Save',
      date: DateTime(2026, 10, 2),
    );

    final result = await summary();
    expect(result.totalIncomeCents, 10000);
    expect(result.totalExpenseCents, 3000);
    expect(result.cashBalanceCents, 5000);
    expect(result.savingsBalanceCents, 2000);
  });

  test('overspending is rejected without changing balances', () async {
    await addIncomeCents(1000);

    await expectLater(addExpenseCents(1001), throwsA(isA<ValidationFailure>()));

    final result = await summary();
    expect(result.cashBalanceCents, 1000);
    expect(await expenseRepository.watchExpenses().first, isEmpty);
  });

  test('transferring more than the source balance is rejected', () async {
    await addIncomeCents(1000);

    await expectLater(
      addTransfer(
        amountCents: 1001,
        from: AccountType.cash,
        to: AccountType.savings,
        note: '',
        date: DateTime(2026, 10, 2),
      ),
      throwsA(isA<ValidationFailure>()),
    );

    await addTransfer(
      amountCents: 500,
      from: AccountType.cash,
      to: AccountType.savings,
      note: '',
      date: DateTime(2026, 10, 2),
    );

    await expectLater(
      addTransfer(
        amountCents: 501,
        from: AccountType.savings,
        to: AccountType.cash,
        note: '',
        date: DateTime(2026, 10, 3),
      ),
      throwsA(isA<ValidationFailure>()),
    );

    final result = await summary();
    expect(result.cashBalanceCents, 500);
    expect(result.savingsBalanceCents, 500);
  });

  test('zero and negative amounts are rejected', () async {
    expect(
      () => addIncome(
        amountCents: 0,
        categoryId: salaryCategoryId,
        note: '',
        date: DateTime(2026, 10, 1),
      ),
      throwsA(isA<ValidationFailure>()),
    );
    expect(
      () => addIncome(
        amountCents: -1,
        categoryId: salaryCategoryId,
        note: '',
        date: DateTime(2026, 10, 1),
      ),
      throwsA(isA<ValidationFailure>()),
    );
    await expectLater(
      addExpense(
        amountCents: 0,
        categoryId: foodCategoryId,
        note: '',
        date: DateTime(2026, 10, 1),
      ),
      throwsA(isA<ValidationFailure>()),
    );
    await expectLater(
      addExpense(
        amountCents: -1,
        categoryId: foodCategoryId,
        note: '',
        date: DateTime(2026, 10, 1),
      ),
      throwsA(isA<ValidationFailure>()),
    );
    await expectLater(
      addTransfer(
        amountCents: 0,
        from: AccountType.cash,
        to: AccountType.savings,
        note: '',
        date: DateTime(2026, 10, 1),
      ),
      throwsA(isA<ValidationFailure>()),
    );
    await expectLater(
      addTransfer(
        amountCents: -1,
        from: AccountType.cash,
        to: AccountType.savings,
        note: '',
        date: DateTime(2026, 10, 1),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test(
    'editing and deleting transactions keeps every balance correct',
    () async {
      await addIncomeCents(10000);
      await addExpenseCents(2000);

      var expenses = await expenseRepository.watchExpenses().first;
      final expenseId = expenses.single.id;

      await updateExpense(
        id: expenseId,
        amountCents: 3000,
        categoryId: foodCategoryId,
        note: 'Updated expense',
        date: DateTime(2026, 10, 1),
      );
      expect((await summary()).cashBalanceCents, 7000);

      await expectLater(
        updateExpense(
          id: expenseId,
          amountCents: 11000,
          categoryId: foodCategoryId,
          note: 'Too large',
          date: DateTime(2026, 10, 1),
        ),
        throwsA(isA<ValidationFailure>()),
      );
      expenses = await expenseRepository.watchExpenses().first;
      expect(expenses.single.amountCents, 3000);
      expect((await summary()).cashBalanceCents, 7000);

      await addTransfer(
        amountCents: 1000,
        from: AccountType.cash,
        to: AccountType.savings,
        note: 'Save',
        date: DateTime(2026, 10, 2),
      );
      final transferId =
          (await transferRepository.watchTransfers().first).single.id;

      await updateTransfer(
        id: transferId,
        amountCents: 2000,
        from: AccountType.cash,
        to: AccountType.savings,
        note: 'Updated transfer',
        date: DateTime(2026, 10, 2),
      );
      var result = await summary();
      expect(result.cashBalanceCents, 5000);
      expect(result.savingsBalanceCents, 2000);

      await expectLater(
        updateTransfer(
          id: transferId,
          amountCents: 8000,
          from: AccountType.cash,
          to: AccountType.savings,
          note: 'Too large',
          date: DateTime(2026, 10, 2),
        ),
        throwsA(isA<ValidationFailure>()),
      );
      expect(
        (await transferRepository.watchTransfers().first).single.amountCents,
        2000,
      );
      result = await summary();
      expect(result.cashBalanceCents, 5000);
      expect(result.savingsBalanceCents, 2000);

      await deleteTransfer(transferId);
      result = await summary();
      expect(result.cashBalanceCents, 7000);
      expect(result.savingsBalanceCents, 0);

      await deleteExpense(expenseId);
      result = await summary();
      expect(result.cashBalanceCents, 10000);

      final incomeId = (await incomeRepository.watchIncomes().first).single.id;
      await deleteIncome(incomeId);
      result = await summary();
      expect(result.cashBalanceCents, 0);
      expect(result.totalBalanceCents, 0);
    },
  );

  test(
    'rejects income edits or deletions that would make Cash negative',
    () async {
      await addIncomeCents(1000);
      await addExpenseCents(800);
      final incomeId = (await incomeRepository.watchIncomes().first).single.id;
      final expenseId =
          (await expenseRepository.watchExpenses().first).single.id;

      await expectLater(
        updateIncome(
          id: incomeId,
          amountCents: 500,
          categoryId: salaryCategoryId,
          note: 'Too low',
          date: DateTime(2026, 10, 1),
        ),
        throwsA(isA<ValidationFailure>()),
      );
      expect(
        (await incomeRepository.watchIncomes().first).single.amountCents,
        1000,
      );
      expect((await summary()).cashBalanceCents, 200);

      await expectLater(
        deleteIncome(incomeId),
        throwsA(isA<ValidationFailure>()),
      );
      expect(await incomeRepository.watchIncomes().first, hasLength(1));

      await deleteExpense(expenseId);
      await deleteIncome(incomeId);
      expect(await incomeRepository.watchIncomes().first, isEmpty);
      expect((await summary()).cashBalanceCents, 0);
    },
  );

  test(
    'persists balances and transactions after reopening the database',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'penny_note_persistence_',
      );
      addTearDown(() async {
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      });
      final file = File('${directory.path}/penny_note.sqlite');

      var database = AppDatabase.forTesting(NativeDatabase(file));
      var accounts = AccountRepositoryImpl(
        AccountLocalDataSource(database.accountDao),
      );
      var expenses = ExpenseRepositoryImpl(
        ExpenseLocalDataSource(database.expenseDao),
      );
      var incomes = IncomeRepositoryImpl(
        IncomeLocalDataSource(database.incomeDao),
      );
      var transfers = TransferRepositoryImpl(
        TransferLocalDataSource(database.transferDao),
      );
      final categories = await database.incomeCategoryDao.watchAll().first;
      final salary = categories.firstWhere(
        (category) => category.name == 'Salary',
      );
      final expenseCategories = await database.categoryDao.watchAll().first;
      final food = expenseCategories.firstWhere(
        (category) => category.name == 'Food',
      );

      await AddIncome(incomes)(
        amountCents: 5000,
        categoryId: salary.id,
        note: 'Persisted income',
        date: DateTime(2026, 10, 1),
      );
      await AddExpense(expenses, accounts)(
        amountCents: 1000,
        categoryId: food.id,
        note: 'Persisted expense',
        date: DateTime(2026, 10, 1),
      );
      await AddTransfer(transfers, accounts)(
        amountCents: 2000,
        from: AccountType.cash,
        to: AccountType.savings,
        note: 'Persisted transfer',
        date: DateTime(2026, 10, 2),
      );
      final before = await accounts.currentSummary();
      expect(before.cashBalanceCents, 2000);
      expect(before.savingsBalanceCents, 2000);
      expect(before.totalBalanceCents, 4000);
      await database.close();

      database = AppDatabase.forTesting(NativeDatabase(file));
      accounts = AccountRepositoryImpl(
        AccountLocalDataSource(database.accountDao),
      );
      final after = await accounts.currentSummary();
      expect(after.cashBalanceCents, 2000);
      expect(after.savingsBalanceCents, 2000);
      expect(after.totalBalanceCents, 4000);
      expect(await database.incomeDao.watchAll().first, hasLength(1));
      expect(await database.expenseDao.watchAll().first, hasLength(1));
      expect(await database.transferDao.watchAll().first, hasLength(1));
      await database.close();
    },
  );
}
