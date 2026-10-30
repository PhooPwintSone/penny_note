import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/app.dart';
import 'package:penny_note/core/utils/money.dart';
import 'package:penny_note/features/accounts/domain/entities/financial_summary.dart';
import 'package:penny_note/features/accounts/presentation/providers/account_providers.dart';
import 'package:penny_note/features/categories/domain/entities/category.dart';
import 'package:penny_note/features/categories/presentation/providers/category_providers.dart';
import 'package:penny_note/features/expenses/domain/entities/expense.dart';
import 'package:penny_note/features/expenses/presentation/providers/expense_providers.dart';
import 'package:penny_note/features/income/domain/entities/income.dart';
import 'package:penny_note/features/income/presentation/providers/income_providers.dart';
import 'package:penny_note/features/settings/presentation/providers/settings_providers.dart';

void main() {
  testWidgets('dashboard renders the empty state without fake data', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Total Balance · MMK'), findsOneWidget);
    expect(find.text('Ks 0'), findsWidgets);
    expect(find.text('No expenses yet.'), findsOneWidget);
  });

  testWidgets('dashboard displays the selected currency and ISO code', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestApp(currency: AppCurrency.usd));
    await tester.pumpAndSettle();

    expect(find.text('Total Balance · USD'), findsOneWidget);
    expect(find.text(r'$ 0.00'), findsWidgets);
    expect(find.text('Ks 0'), findsNothing);
  });

  testWidgets('settings shows the currency picker when the journal is empty', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestApp(currency: AppCurrency.usd));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Base currency'), findsOneWidget);
    expect(find.text(r'US Dollar (USD) · $'), findsOneWidget);

    await tester.tap(find.text('Base currency'));
    await tester.pumpAndSettle();

    expect(find.text('Choose currency'), findsOneWidget);
    expect(find.text('Myanmar Kyat'), findsOneWidget);
    expect(find.text('Canadian Dollar'), findsOneWidget);
    expect(find.text('Singapore Dollar'), findsOneWidget);
    expect(find.text('Thai Baht'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('settings explains why currency is locked with records', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestApp(hasFinancialRecords: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Currency is locked because your journal already contains '
        'transactions. Changing it would require converting existing amounts.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Base currency'));
    await tester.pumpAndSettle();

    expect(find.text('Currency is locked'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
  });

  testWidgets('settings can switch the app to dark mode', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  testWidgets('phones use bottom navigation', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('income tab opens the income journal', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Income'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No income recorded yet'), findsOneWidget);
    expect(find.byTooltip('Add income'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tab floating action buttons do not share a Hero tag', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add expense'));
    await tester.pumpAndSettle();

    expect(find.text('Add expense'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablets and desktops use a navigation rail', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}

Widget _buildTestApp({
  AppCurrency currency = AppCurrency.mmk,
  bool hasFinancialRecords = false,
}) {
  return ProviderScope(
    overrides: [
      // Tests never open SQLite; the dashboard receives an empty journal.
      expensesStreamProvider.overrideWith(
        (ref) => Stream.value(const <Expense>[]),
      ),
      categoriesStreamProvider.overrideWith(
        (ref) => Stream.value(const [
          Category(id: 1, name: 'Food', icon: 'restaurant'),
        ]),
      ),
      incomesStreamProvider.overrideWith(
        (ref) => Stream.value(const <Income>[]),
      ),
      financialSummaryStreamProvider.overrideWith(
        (ref) => Stream.value(FinancialSummary.empty),
      ),
      currencyProvider.overrideWithValue(currency),
      hasFinancialRecordsStreamProvider.overrideWith(
        (ref) => Stream.value(hasFinancialRecords),
      ),
    ],
    child: const PennyNoteApp(),
  );
}
