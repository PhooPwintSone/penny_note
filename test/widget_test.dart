import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/app.dart';
import 'package:penny_note/features/expenses/domain/entities/expense.dart';
import 'package:penny_note/features/expenses/presentation/providers/expense_providers.dart';
import 'package:penny_note/features/savings/domain/entities/savings_entry.dart';
import 'package:penny_note/features/savings/presentation/providers/savings_providers.dart';

void main() {
  testWidgets('dashboard renders the empty state without fake data', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Your Balance'), findsOneWidget);
    expect(find.text('K 0'), findsWidgets);
    expect(find.text('No expenses yet.'), findsOneWidget);
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

Widget _buildTestApp() {
  return ProviderScope(
    overrides: [
      // Tests never open SQLite; the dashboard receives an empty journal.
      expensesStreamProvider.overrideWith(
        (ref) => Stream.value(const <Expense>[]),
      ),
      savingsStreamProvider.overrideWith(
        (ref) => Stream.value(const <SavingsEntry>[]),
      ),
    ],
    child: const PennyNoteApp(),
  );
}
