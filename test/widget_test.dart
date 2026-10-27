import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/app.dart';
import 'package:penny_note/features/expenses/domain/entities/expense.dart';
import 'package:penny_note/features/expenses/presentation/providers/expense_providers.dart';

void main() {
  testWidgets('dashboard renders the empty state without fake data', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Your Balance'), findsOneWidget);
    expect(find.text(r'$0.00'), findsWidgets);
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
}

Widget _buildTestApp() {
  return ProviderScope(
    overrides: [
      // Tests never open SQLite; the dashboard receives an empty journal.
      expensesStreamProvider.overrideWith(
        (ref) => Stream.value(const <Expense>[]),
      ),
    ],
    child: const PennyNoteApp(),
  );
}
