import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_note/core/theme/app_theme.dart';
import 'package:penny_note/core/utils/money.dart';
import 'package:penny_note/features/accounts/domain/entities/financial_summary.dart';
import 'package:penny_note/features/accounts/presentation/providers/account_providers.dart';
import 'package:penny_note/features/income/domain/entities/income.dart';
import 'package:penny_note/features/income/domain/entities/income_category.dart';
import 'package:penny_note/features/income/domain/repositories/income_repository.dart';
import 'package:penny_note/features/income/presentation/providers/income_category_providers.dart';
import 'package:penny_note/features/income/presentation/providers/income_providers.dart';
import 'package:penny_note/features/income/presentation/screens/add_income_screen.dart';
import 'package:penny_note/features/settings/presentation/providers/settings_providers.dart';

import '../../../../support/fake_account_repository.dart';

void main() {
  testWidgets('save button stores a valid income entry', (tester) async {
    final repository = _FakeIncomeRepository();
    final accounts = FakeAccountRepository(
      summary: const FinancialSummary(
        totalIncomeCents: 0,
        totalExpenseCents: 0,
        cashBalanceCents: 0,
        savingsBalanceCents: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomeRepositoryProvider.overrideWithValue(repository),
          accountRepositoryProvider.overrideWithValue(accounts),
          currencyProvider.overrideWithValue(AppCurrency.mmk),
          incomeCategoriesStreamProvider.overrideWith(
            (ref) => Stream.value(const [
              IncomeCategory(id: 1, name: 'Salary', icon: 'payments'),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const AddIncomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final amountField = tester.widget<TextField>(find.byType(TextField).first);
    expect(amountField.decoration?.labelText, 'Amount (MMK)');
    expect(amountField.decoration?.prefixText, 'Ks ');
    expect(amountField.decoration?.helperText, 'Myanmar Kyat');

    await tester.enterText(find.byType(TextField).first, '12.50');
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salary').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save income'));
    await tester.pumpAndSettle();

    expect(repository.added, hasLength(1));
    expect(repository.added.single.amountCents, 1250);
    expect(repository.added.single.categoryId, 1);
  });

  testWidgets('edit form pre-fills and updates an existing income entry', (
    tester,
  ) async {
    final repository = _FakeIncomeRepository();
    final accounts = FakeAccountRepository(
      summary: const FinancialSummary(
        totalIncomeCents: 100000,
        totalExpenseCents: 0,
        cashBalanceCents: 100000,
        savingsBalanceCents: 0,
      ),
    );
    final income = Income(
      id: 7,
      amountCents: 1250,
      category: const IncomeCategory(id: 1, name: 'Salary', icon: 'payments'),
      note: 'Monthly pay',
      date: DateTime(2026, 10, 27),
      createdAt: DateTime(2026, 10, 27),
      updatedAt: DateTime(2026, 10, 27),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomeRepositoryProvider.overrideWithValue(repository),
          accountRepositoryProvider.overrideWithValue(accounts),
          currencyProvider.overrideWithValue(AppCurrency.mmk),
          incomeCategoriesStreamProvider.overrideWith(
            (ref) => Stream.value(const [
              IncomeCategory(id: 1, name: 'Salary', icon: 'payments'),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: AddIncomeScreen(income: income),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit income'), findsOneWidget);
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

class _FakeIncomeRepository implements IncomeRepository {
  final List<({int amountCents, int categoryId, String note, DateTime date})>
  added = [];
  final List<
    ({int id, int amountCents, int categoryId, String note, DateTime date})
  >
  updated = [];

  @override
  Stream<List<Income>> watchIncomes() => const Stream.empty();

  @override
  Future<void> addIncome({
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
  Future<void> updateIncome({
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
  Future<void> deleteIncome(int id) async {}

  @override
  Future<int?> amountCentsById(int id) async => 1250;
}
