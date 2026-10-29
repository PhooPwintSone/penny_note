import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/errors/app_failure.dart';
import 'package:penny_note/features/accounts/domain/entities/financial_summary.dart';
import 'package:penny_note/features/expenses/domain/entities/expense.dart';
import 'package:penny_note/features/expenses/domain/repositories/expense_repository.dart';
import 'package:penny_note/features/expenses/domain/usecases/update_expense.dart';

import '../../../../support/fake_account_repository.dart';

void main() {
  late _FakeExpenseRepository repository;
  late FakeAccountRepository accounts;
  late UpdateExpense updateExpense;

  setUp(() {
    repository = _FakeExpenseRepository();
    accounts = FakeAccountRepository(
      summary: const FinancialSummary(
        totalIncomeCents: 1000,
        totalExpenseCents: 400,
        cashBalanceCents: 600,
        savingsBalanceCents: 0,
      ),
    );
    updateExpense = UpdateExpense(repository, accounts);
  });

  test('updates a valid expense with a trimmed note', () async {
    await updateExpense(
      id: 4,
      amountCents: 450,
      categoryId: 2,
      note: '  Flat white  ',
      date: DateTime(2026, 10, 27),
    );

    expect(repository.updated, hasLength(1));
    expect(repository.updated.single.id, 4);
    expect(repository.updated.single.amountCents, 450);
    expect(repository.updated.single.note, 'Flat white');
    expect(repository.updated.single.categoryId, 2);
  });

  test(
    'rejects an edit above the available Cash and keeps the original',
    () async {
      await expectLater(
        updateExpense(
          id: 4,
          amountCents: 1001,
          categoryId: 2,
          note: '',
          date: DateTime(2026, 10, 27),
        ),
        throwsA(isA<ValidationFailure>()),
      );

      expect(repository.updated, isEmpty);
    },
  );

  test('rejects an invalid id, amount, category or note', () async {
    await expectLater(
      updateExpense(
        id: 0,
        amountCents: 450,
        categoryId: 2,
        note: '',
        date: DateTime(2026, 10, 27),
      ),
      throwsA(isA<ValidationFailure>()),
    );
    await expectLater(
      updateExpense(
        id: 4,
        amountCents: 0,
        categoryId: 2,
        note: '',
        date: DateTime(2026, 10, 27),
      ),
      throwsA(isA<ValidationFailure>()),
    );
    await expectLater(
      updateExpense(
        id: 4,
        amountCents: 450,
        categoryId: 0,
        note: '',
        date: DateTime(2026, 10, 27),
      ),
      throwsA(isA<ValidationFailure>()),
    );
    await expectLater(
      updateExpense(
        id: 4,
        amountCents: 450,
        categoryId: 2,
        note: 'x' * 201,
        date: DateTime(2026, 10, 27),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });
}

class _FakeExpenseRepository implements ExpenseRepository {
  final List<
    ({int id, int amountCents, int categoryId, String note, DateTime date})
  >
  updated = [];

  @override
  Stream<List<Expense>> watchExpenses() => const Stream.empty();

  @override
  Future<void> addExpense({
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) async {}

  @override
  Future<void> updateExpense({
    required int id,
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) async {
    updated.add((
      id: id,
      amountCents: amountCents,
      categoryId: categoryId,
      note: note,
      date: date,
    ));
  }

  @override
  Future<void> deleteExpense(int id) async {}

  @override
  Future<int?> amountCentsById(int id) async => 400;
}
