import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/theme/app_theme.dart';
import 'package:penny_note/features/categories/domain/entities/category.dart';
import 'package:penny_note/features/expenses/domain/entities/expense.dart';
import 'package:penny_note/features/expenses/presentation/providers/expense_providers.dart';
import 'package:penny_note/features/home/presentation/screens/home_screen.dart';
import 'package:penny_note/features/savings/domain/entities/savings_entry.dart';
import 'package:penny_note/features/savings/presentation/providers/savings_providers.dart';

void main() {
  testWidgets('dashboard shows totals and recent expenses on a phone screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final expense = Expense(
      id: 1,
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
          expensesStreamProvider.overrideWith((ref) => Stream.value([expense])),
          savingsStreamProvider.overrideWith(
            (ref) => Stream.value(const <SavingsEntry>[]),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('K 12.50'), findsWidgets);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Savings'), findsOneWidget);
    expect(find.text('Recent Expenses'), findsOneWidget);
    expect(find.text('No expenses yet.'), findsNothing);
  });
}
