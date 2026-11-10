import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_filter.dart';
import '../../domain/entities/income.dart';
import '../providers/income_providers.dart';

class IncomesState {
  const IncomesState(
    this.incomes, {
    this.selectedFilter = DateFilterSelection.initial,
  });

  final List<Income> incomes;
  final DateFilterSelection selectedFilter;

  bool get isEmpty => incomes.isEmpty;

  /// The loaded income entries narrowed to [selectedFilter], ignoring time.
  List<Income> get filteredIncomes {
    final now = DateTime.now();
    return incomes
        .where((income) => selectedFilter.matches(income.date, now))
        .toList(growable: false);
  }

  IncomesState withFilter(DateFilterSelection filter) {
    return IncomesState(incomes, selectedFilter: filter);
  }
}

class IncomesViewModel extends AsyncNotifier<IncomesState> {
  DateFilterSelection _selectedFilter = DateFilterSelection.initial;

  @override
  Future<IncomesState> build() async {
    final incomes = await ref.watch(incomesStreamProvider.future);
    return IncomesState(incomes, selectedFilter: _selectedFilter);
  }

  /// Updates the range filter without changing the underlying Drift query.
  void setFilter(DateFilterSelection filter) {
    _selectedFilter = filter;
    state = state.whenData((current) => current.withFilter(filter));
  }

  void resetFilter() => setFilter(DateFilterSelection.initial);

  /// Deletes an income entry. The list refreshes through the Drift stream;
  /// errors are rethrown so the screen can show a message.
  Future<void> deleteIncome(int id) {
    return ref.read(deleteIncomeUseCaseProvider)(id);
  }
}

final incomesViewModelProvider =
    AsyncNotifierProvider<IncomesViewModel, IncomesState>(IncomesViewModel.new);
