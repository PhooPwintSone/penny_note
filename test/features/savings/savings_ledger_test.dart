import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/database/app_database.dart';
import 'package:penny_note/core/errors/app_failure.dart';
import 'package:penny_note/features/savings/data/datasources/savings_local_data_source.dart';
import 'package:penny_note/features/savings/data/repositories/savings_repository_impl.dart';
import 'package:penny_note/features/savings/domain/repositories/savings_repository.dart';
import 'package:penny_note/features/savings/domain/usecases/add_savings.dart';
import 'package:penny_note/features/savings/domain/usecases/delete_savings.dart';

void main() {
  late AppDatabase database;
  late SavingsRepository repository;
  late AddSavings addSavings;
  late DeleteSavings deleteSavings;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SavingsRepositoryImpl(
      SavingsLocalDataSource(database.savingsDao),
    );
    addSavings = AddSavings(repository);
    deleteSavings = DeleteSavings(repository);
  });

  tearDown(() => database.close());

  test('tracks deposits and withdrawals in the running total', () async {
    await addSavings(
      amountCents: 1000,
      isWithdrawal: false,
      note: '  Monthly  ',
      date: DateTime(2026, 10, 1),
    );
    expect(await repository.totalSavingsCents(), 1000);

    await addSavings(
      amountCents: 400,
      isWithdrawal: true,
      note: 'Emergency',
      date: DateTime(2026, 10, 2),
    );
    expect(await repository.totalSavingsCents(), 600);

    final entries = await repository.watchSavings().first;
    expect(entries, hasLength(2));
    expect(entries.last.note, 'Monthly');
  });

  test('rejects a withdrawal larger than the current savings', () async {
    await addSavings(
      amountCents: 1000,
      isWithdrawal: false,
      note: '',
      date: DateTime(2026, 10, 1),
    );

    expect(
      () => addSavings(
        amountCents: 1001,
        isWithdrawal: true,
        note: '',
        date: DateTime(2026, 10, 2),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('prevents a deposit deletion from making savings negative', () async {
    await addSavings(
      amountCents: 1000,
      isWithdrawal: false,
      note: 'Deposit',
      date: DateTime(2026, 10, 1),
    );
    await addSavings(
      amountCents: 400,
      isWithdrawal: true,
      note: 'Withdrawal',
      date: DateTime(2026, 10, 2),
    );

    final entries = await repository.watchSavings().first;
    final deposit = entries.firstWhere((entry) => !entry.isWithdrawal);
    final withdrawal = entries.firstWhere((entry) => entry.isWithdrawal);

    expect(() => deleteSavings(deposit.id), throwsA(isA<ValidationFailure>()));

    await deleteSavings(withdrawal.id);
    expect(await repository.totalSavingsCents(), 1000);

    await deleteSavings(deposit.id);
    expect(await repository.totalSavingsCents(), 0);
  });
}
