import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../income/domain/entities/income.dart';
import '../../../income/presentation/providers/income_providers.dart';
import '../../../savings/presentation/providers/savings_providers.dart';

/// View state for the dashboard.
///
/// Income and expense totals are independent; savings is a separate ledger
/// shown as its own shortcut on the dashboard.
class HomeState {
  const HomeState({
    required this.totalIncomeCents,
    required this.totalExpenseCents,
    required this.totalSavingsCents,
    required this.recentExpenses,
  });

  static const recentExpenseLimit = 3;

  factory HomeState.fromData(
    List<Expense> expenses,
    List<Income> incomes, {
    int totalSavingsCents = 0,
  }) {
    final totalExpenseCents = expenses.fold<int>(
      0,
      (total, expense) => total + expense.amountCents,
    );
    final totalIncomeCents = incomes.fold<int>(
      0,
      (total, income) => total + income.amountCents,
    );

    return HomeState(
      totalIncomeCents: totalIncomeCents,
      totalExpenseCents: totalExpenseCents,
      totalSavingsCents: totalSavingsCents,
      recentExpenses: expenses.take(recentExpenseLimit).toList(growable: false),
    );
  }

  final int totalIncomeCents;
  final int totalExpenseCents;
  final int totalSavingsCents;
  final List<Expense> recentExpenses;

  int get balanceCents => totalIncomeCents - totalExpenseCents;
  bool get hasExpenses => recentExpenses.isNotEmpty;
}

class HomeViewModel extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final expenses = await ref.watch(expensesStreamProvider.future);
    final incomes = await ref.watch(incomesStreamProvider.future);
    final savings = await ref.watch(savingsStreamProvider.future);
    final totalSavingsCents = savings.fold<int>(
      0,
      (total, entry) => total + entry.signedAmountCents,
    );
    return HomeState.fromData(
      expenses,
      incomes,
      totalSavingsCents: totalSavingsCents,
    );
  }
}

final homeViewModelProvider = AsyncNotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);
