import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/errors/app_failure.dart';
import 'package:penny_note/features/expenses/domain/entities/expense.dart';
import 'package:penny_note/features/expenses/domain/repositories/expense_repository.dart';
import 'package:penny_note/features/expenses/domain/usecases/add_expense.dart';

void main() {
  late _FakeExpenseRepository repository;
  late AddExpense addExpense;

  setUp(() {
    repository = _FakeExpenseRepository();
    addExpense = AddExpense(repository);
  });

  test('stores a valid expense with a trimmed note', () async {
    await addExpense(
      amountCents: 450,
      categoryId: 1,
      note: '  Flat white  ',
      date: DateTime(2026, 10, 27),
    );

    expect(repository.added, hasLength(1));
    expect(repository.added.single.amountCents, 450);
    expect(repository.added.single.note, 'Flat white');
    expect(repository.added.single.categoryId, 1);
  });

  test('rejects a non-positive amount', () {
    expect(
      () => addExpense(
        amountCents: 0,
        categoryId: 1,
        note: '',
        date: DateTime(2026, 10, 27),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('rejects a missing category', () {
    expect(
      () => addExpense(
        amountCents: 500,
        categoryId: 0,
        note: '',
        date: DateTime(2026, 10, 27),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('rejects notes longer than 200 characters', () {
    expect(
      () => addExpense(
        amountCents: 500,
        categoryId: 1,
        note: 'x' * (AddExpense.maxNoteLength + 1),
        date: DateTime(2026, 10, 27),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });
}

class _FakeExpenseRepository implements ExpenseRepository {
  final List<({int amountCents, int categoryId, String note, DateTime date})>
  added = [];

  @override
  Stream<List<Expense>> watchExpenses() => const Stream.empty();

  @override
  Future<void> addExpense({
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) async {
    added.add((
      amountCents: amountCents,
      categoryId: categoryId,
      note: note,
      date: date,
    ));
  }

  @override
  Future<void> updateExpense({
    required int id,
    required int amountCents,
    required int categoryId,
    required String note,
    required DateTime date,
  }) async {}

  @override
  Future<void> deleteExpense(int id) async {}
}
