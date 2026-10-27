import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/expense.dart';
import '../providers/expense_providers.dart';

class ExpensesState {
  const ExpensesState(this.expenses);

  final List<Expense> expenses;

  bool get isEmpty => expenses.isEmpty;
}

class ExpensesViewModel extends AsyncNotifier<ExpensesState> {
  @override
  Future<ExpensesState> build() async {
    final expenses = await ref.watch(expensesStreamProvider.future);
    return ExpensesState(expenses);
  }

  /// Deletes an expense. The list refreshes through the Drift stream; errors
  /// are rethrown so the screen can show a message.
  Future<void> deleteExpense(int id) {
    return ref.read(deleteExpenseUseCaseProvider)(id);
  }
}

final expensesViewModelProvider =
    AsyncNotifierProvider<ExpensesViewModel, ExpensesState>(
      ExpensesViewModel.new,
    );
