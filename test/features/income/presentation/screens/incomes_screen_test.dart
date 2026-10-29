import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/theme/app_theme.dart';
import 'package:penny_note/features/income/domain/entities/income.dart';
import 'package:penny_note/features/income/domain/entities/income_category.dart';
import 'package:penny_note/features/income/presentation/providers/income_providers.dart';
import 'package:penny_note/features/income/presentation/screens/incomes_screen.dart';

void main() {
  testWidgets('income list fits a narrow phone and exposes edit/delete', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final income = Income(
      id: 1,
      amountCents: 123456,
      category: const IncomeCategory(id: 1, name: 'Salary', icon: 'payments'),
      note: 'A long note that must not push the row apart',
      date: DateTime(2026, 10, 27),
      createdAt: DateTime(2026, 10, 27),
      updatedAt: DateTime(2026, 10, 27),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomesStreamProvider.overrideWith((ref) => Stream.value([income])),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const IncomesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 entry'), findsOneWidget);
    expect(find.byTooltip('Income options'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
