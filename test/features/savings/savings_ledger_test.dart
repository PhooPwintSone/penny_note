import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/database/app_database.dart';
import 'package:penny_note/core/errors/app_failure.dart';
import 'package:penny_note/features/accounts/data/datasources/account_local_data_source.dart';
import 'package:penny_note/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:penny_note/features/accounts/domain/entities/account_type.dart';
import 'package:penny_note/features/accounts/domain/repositories/account_repository.dart';
import 'package:penny_note/features/savings/data/datasources/transfer_local_data_source.dart';
import 'package:penny_note/features/savings/data/repositories/transfer_repository_impl.dart';
import 'package:penny_note/features/savings/domain/repositories/transfer_repository.dart';
import 'package:penny_note/features/savings/domain/usecases/add_transfer.dart';
import 'package:penny_note/features/savings/domain/usecases/delete_transfer.dart';

void main() {
  late AppDatabase database;
  late AccountRepository accounts;
  late TransferRepository repository;
  late AddTransfer addTransfer;
  late DeleteTransfer deleteTransfer;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    accounts = AccountRepositoryImpl(
      AccountLocalDataSource(database.accountDao),
    );
    repository = TransferRepositoryImpl(
      TransferLocalDataSource(database.transferDao),
    );
    addTransfer = AddTransfer(repository, accounts);
    deleteTransfer = DeleteTransfer(repository, accounts);
  });

  tearDown(() => database.close());

  Future<void> seedCash(int amountCents) async {
    final categories = await database.incomeCategoryDao.watchAll().first;
    final salary = categories.firstWhere(
      (category) => category.name == 'Salary',
    );
    await database.incomeDao.insertIncome(
      IncomesCompanion.insert(
        amountCents: amountCents,
        categoryId: salary.id,
        date: DateTime(2026, 10, 1),
      ),
    );
  }

  test(
    'tracks Cash to Savings and Savings to Cash in the savings total',
    () async {
      await seedCash(5000);
      await addTransfer(
        amountCents: 1000,
        from: AccountType.cash,
        to: AccountType.savings,
        note: '  Monthly  ',
        date: DateTime(2026, 10, 1),
      );

      var summary = await accounts.currentSummary();
      expect(summary.cashBalanceCents, 4000);
      expect(summary.savingsBalanceCents, 1000);

      await addTransfer(
        amountCents: 400,
        from: AccountType.savings,
        to: AccountType.cash,
        note: 'Emergency',
        date: DateTime(2026, 10, 2),
      );

      summary = await accounts.currentSummary();
      expect(summary.cashBalanceCents, 4400);
      expect(summary.savingsBalanceCents, 600);

      final transfers = await repository.watchTransfers().first;
      expect(transfers, hasLength(2));
      expect(transfers.last.note, 'Monthly');
    },
  );

  test('rejects a withdrawal larger than the current savings', () async {
    await seedCash(5000);
    await addTransfer(
      amountCents: 1000,
      from: AccountType.cash,
      to: AccountType.savings,
      note: '',
      date: DateTime(2026, 10, 1),
    );

    await expectLater(
      addTransfer(
        amountCents: 1001,
        from: AccountType.savings,
        to: AccountType.cash,
        note: '',
        date: DateTime(2026, 10, 2),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('prevents a deposit deletion from making savings negative', () async {
    await seedCash(5000);
    await addTransfer(
      amountCents: 1000,
      from: AccountType.cash,
      to: AccountType.savings,
      note: 'Deposit',
      date: DateTime(2026, 10, 1),
    );
    await addTransfer(
      amountCents: 400,
      from: AccountType.savings,
      to: AccountType.cash,
      note: 'Withdrawal',
      date: DateTime(2026, 10, 2),
    );

    final transfers = await repository.watchTransfers().first;
    final deposit = transfers.firstWhere((transfer) => transfer.isDeposit);
    final withdrawal = transfers.firstWhere(
      (transfer) => transfer.isWithdrawal,
    );

    await expectLater(
      deleteTransfer(deposit.id),
      throwsA(isA<ValidationFailure>()),
    );

    await deleteTransfer(withdrawal.id);
    expect((await accounts.currentSummary()).savingsBalanceCents, 1000);

    await deleteTransfer(deposit.id);
    expect((await accounts.currentSummary()).savingsBalanceCents, 0);
  });
}
