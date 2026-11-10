import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/theme/app_theme.dart';
import 'package:penny_note/core/utils/date_formats.dart';
import 'package:penny_note/core/utils/money.dart';
import 'package:penny_note/features/categories/domain/entities/category.dart';
import 'package:penny_note/features/expenses/domain/entities/expense.dart';
import 'package:penny_note/features/expenses/presentation/providers/expense_providers.dart';
import 'package:penny_note/features/income/domain/entities/income.dart';
import 'package:penny_note/features/income/domain/entities/income_category.dart';
import 'package:penny_note/features/income/presentation/providers/income_providers.dart';
import 'package:penny_note/features/settings/presentation/providers/settings_providers.dart';
import 'package:penny_note/features/statistics/presentation/screens/statistics_screen.dart';

void main() {
  testWidgets('statistics shows monthly totals and category breakdowns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final expense = Expense(
      id: 1,
      amountCents: 50000,
      category: const Category(id: 1, name: 'Food', icon: 'restaurant'),
      note: 'Lunch',
      date: now,
      createdAt: now,
      updatedAt: now,
    );
    final income = Income(
      id: 1,
      amountCents: 100000,
      category: const IncomeCategory(id: 1, name: 'Salary', icon: 'payments'),
      note: 'Payday',
      date: now,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expensesStreamProvider.overrideWith((ref) => Stream.value([expense])),
          incomesStreamProvider.overrideWith((ref) => Stream.value([income])),
          currencyProvider.overrideWithValue(AppCurrency.mmk),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const StatisticsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Monthly trend'), findsOneWidget);
    expect(find.text('Income'), findsWidgets);
    expect(find.text('Expenses'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Expense categories'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Expense categories'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Income categories'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Income categories'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
  });

  testWidgets('statistics shows an empty month and can move back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expensesStreamProvider.overrideWith((ref) => Stream.value([])),
          incomesStreamProvider.overrideWith((ref) => Stream.value([])),
          currencyProvider.overrideWithValue(AppCurrency.mmk),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const StatisticsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final now = DateTime.now();
    expect(find.text('No activity in ${formatMonthYear(now)}'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();

    final previousMonth = DateTime(now.year, now.month - 1);
    expect(
      find.text('No activity in ${formatMonthYear(previousMonth)}'),
      findsOneWidget,
    );
  });
}
