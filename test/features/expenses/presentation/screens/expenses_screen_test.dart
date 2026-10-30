import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/theme/app_theme.dart';
import 'package:penny_note/core/utils/money.dart';
import 'package:penny_note/features/categories/domain/entities/category.dart';
import 'package:penny_note/features/expenses/domain/entities/expense.dart';
import 'package:penny_note/features/expenses/presentation/providers/expense_providers.dart';
import 'package:penny_note/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:penny_note/features/settings/presentation/providers/settings_providers.dart';

void main() {
  testWidgets('expense list fits a narrow phone and exposes delete', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final expense = Expense(
      id: 1,
      amountCents: 123456,
      category: const Category(id: 1, name: 'Food', icon: 'restaurant'),
      note: 'A long note that must not push the row apart',
      date: DateTime(2026, 10, 27),
      createdAt: DateTime(2026, 10, 27),
      updatedAt: DateTime(2026, 10, 27),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expensesStreamProvider.overrideWith((ref) => Stream.value([expense])),
          currencyProvider.overrideWithValue(AppCurrency.usd),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const ExpensesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 entry'), findsOneWidget);
    expect(find.byTooltip('Expense options'), findsOneWidget);
    expect(find.text(r'− $ 1,234.56'), findsOneWidget);
  });
}
