import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/theme/app_theme.dart';
import 'package:penny_note/core/utils/money.dart';
import 'package:penny_note/features/accounts/domain/entities/financial_summary.dart';
import 'package:penny_note/features/accounts/presentation/providers/account_providers.dart';
import 'package:penny_note/features/categories/domain/entities/category.dart';
import 'package:penny_note/features/expenses/domain/entities/expense.dart';
import 'package:penny_note/features/expenses/presentation/providers/expense_providers.dart';
import 'package:penny_note/features/home/presentation/screens/home_screen.dart';
import 'package:penny_note/features/settings/presentation/providers/settings_providers.dart';

void main() {
  testWidgets('dashboard shows balances, totals, and recent expenses', (
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
          financialSummaryStreamProvider.overrideWith(
            (ref) => Stream.value(
              const FinancialSummary(
                totalIncomeCents: 250000,
                totalExpenseCents: 1250,
                cashBalanceCents: 248750,
                savingsBalanceCents: 0,
              ),
            ),
          ),
          currencyProvider.overrideWithValue(AppCurrency.mmk),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ks 12.50'), findsWidgets);
    expect(find.text('Ks 2,500'), findsOneWidget);
    expect(find.text('Ks 2,487.50'), findsWidgets);
    expect(find.text('Total Balance · MMK'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.text('Savings'), findsWidgets);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Recent Expenses'), findsOneWidget);
    expect(find.text('No expenses yet.'), findsNothing);
  });
}
