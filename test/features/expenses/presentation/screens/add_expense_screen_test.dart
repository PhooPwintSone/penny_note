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
  Future<void> deleteExpense(int id) async {}
}
