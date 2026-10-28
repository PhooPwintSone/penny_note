import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/theme/app_theme.dart';
import 'package:penny_note/features/categories/domain/entities/category.dart';
import 'package:penny_note/features/categories/presentation/providers/category_providers.dart';
import 'package:penny_note/features/expenses/domain/entities/expense.dart';
import 'package:penny_note/features/expenses/domain/repositories/expense_repository.dart';
import 'package:penny_note/features/expenses/presentation/providers/expense_providers.dart';
import 'package:penny_note/features/expenses/presentation/screens/add_expense_screen.dart';

void main() {
  testWidgets('save button stores a valid expense', (tester) async {
    final repository = _FakeExpenseRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(repository),
          categoriesStreamProvider.overrideWith(
            (ref) => Stream.value(const [
              Category(id: 1, name: 'Food', icon: 'restaurant'),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const AddExpenseScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '12.50');
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();

    expect(repository.added, hasLength(1));
    expect(repository.added.single.amountCents, 1250);
    expect(repository.added.single.categoryId, 1);
  });

  testWidgets('edit form pre-fills and updates an existing expense', (
    tester,
  ) async {
    final repository = _FakeExpenseRepository();
    final expense = Expense(
      id: 7,
      amountCents: 1250,
      category: const Category(id: 1, name: 'Food', icon: 'restaurant'),
      note: 'Lunch',
      date: DateTime(2026, 10, 27),
      createdAt: DateTime(2026, 10, 27),
      updatedAt: DateTime(2026, 10, 27),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(repository),
          categoriesStreamProvider.overrideWith(
            (ref) => Stream.value(const [
              Category(id: 1, name: 'Food', icon: 'restaurant'),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: AddExpenseScreen(expense: expense),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit expense'), findsOneWidget);
    final amountField = tester.widget<TextField>(find.byType(TextField).first);
    expect(amountField.controller?.text, '12.50');

    await tester.enterText(find.byType(TextField).first, '20');
    await tester.ensureVisible(find.text('Save changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(repository.added, isEmpty);
    expect(repository.updated, hasLength(1));
    expect(repository.updated.single.id, 7);
    expect(repository.updated.single.amountCents, 2000);
    expect(repository.updated.single.categoryId, 1);
  });
}

class _FakeExpenseRepository implements ExpenseRepository {
  final List<({int amountCents, int categoryId, String note, DateTime date})>
  added = [];
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
}
