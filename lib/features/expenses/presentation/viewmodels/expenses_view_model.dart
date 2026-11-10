import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_filter.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_providers.dart';

class ExpensesState {
  const ExpensesState(
    this.expenses, {
    this.selectedFilter = DateFilterSelection.initial,
  });

  final List<Expense> expenses;
  final DateFilterSelection selectedFilter;

  bool get isEmpty => expenses.isEmpty;

  /// The loaded expenses narrowed to [selectedFilter], ignoring time.
  List<Expense> get filteredExpenses {
    final now = DateTime.now();
    return expenses
        .where((expense) => selectedFilter.matches(expense.date, now))
        .toList(growable: false);
  }

  ExpensesState withFilter(DateFilterSelection filter) {
    return ExpensesState(expenses, selectedFilter: filter);
  }
}

class ExpensesViewModel extends AsyncNotifier<ExpensesState> {
  DateFilterSelection _selectedFilter = DateFilterSelection.initial;

  @override
  Future<ExpensesState> build() async {
    final expenses = await ref.watch(expensesStreamProvider.future);
    return ExpensesState(expenses, selectedFilter: _selectedFilter);
  }

  /// Updates the range filter without changing the underlying Drift query.
  void setFilter(DateFilterSelection filter) {
    _selectedFilter = filter;
    state = state.whenData((current) => current.withFilter(filter));
  }

  void resetFilter() => setFilter(DateFilterSelection.initial);

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
