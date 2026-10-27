import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';

/// View state for the dashboard.
///
/// Income is always zero for now because the app only records expenses. When
/// income tracking arrives, this state is the single place to extend.
class HomeState {
  const HomeState({
    required this.totalIncomeCents,
    required this.totalExpenseCents,
    required this.recentExpenses,
  });

  static const recentExpenseLimit = 3;

  factory HomeState.fromExpenses(List<Expense> expenses) {
    final totalExpenseCents = expenses.fold<int>(
      0,
      (total, expense) => total + expense.amountCents,
    );

    return HomeState(
      totalIncomeCents: 0,
      totalExpenseCents: totalExpenseCents,
      recentExpenses: expenses.take(recentExpenseLimit).toList(growable: false),
    );
  }

  final int totalIncomeCents;
  final int totalExpenseCents;
  final List<Expense> recentExpenses;

  int get balanceCents => totalIncomeCents - totalExpenseCents;
  bool get hasExpenses => recentExpenses.isNotEmpty;
}

class HomeViewModel extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final expenses = await ref.watch(expensesStreamProvider.future);
    return HomeState.fromExpenses(expenses);
  }
}

final homeViewModelProvider = AsyncNotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);
