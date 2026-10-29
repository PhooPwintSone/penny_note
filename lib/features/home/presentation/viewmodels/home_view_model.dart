import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../accounts/domain/entities/financial_summary.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';

/// View state for the dashboard.
///
/// All money figures come from [FinancialSummary], which is calculated from
/// persisted income, expense, and transfer rows. The dashboard never keeps its
/// own running balance.
class HomeState {
  const HomeState({required this.summary, required this.recentExpenses});

  static const recentExpenseLimit = 3;

  final FinancialSummary summary;
  final List<Expense> recentExpenses;

  int get totalIncomeCents => summary.totalIncomeCents;
  int get totalExpenseCents => summary.totalExpenseCents;
  int get cashBalanceCents => summary.cashBalanceCents;
  int get savingsBalanceCents => summary.savingsBalanceCents;
  int get balanceCents => summary.totalBalanceCents;

  bool get hasExpenses => recentExpenses.isNotEmpty;
}

class HomeViewModel extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final expenses = await ref.watch(expensesStreamProvider.future);
    final summary = await ref.watch(financialSummaryStreamProvider.future);
    return HomeState(
      summary: summary,
      recentExpenses: expenses
          .take(HomeState.recentExpenseLimit)
          .toList(growable: false),
    );
  }
}

final homeViewModelProvider = AsyncNotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);
