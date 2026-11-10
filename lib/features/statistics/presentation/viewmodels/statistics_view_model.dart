import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../income/domain/entities/income.dart';
import '../../../income/presentation/providers/income_providers.dart';
import '../../domain/entities/statistics.dart';
import '../providers/statistics_providers.dart';

class StatisticsState {
  const StatisticsState({required this.snapshot});

  final StatisticsSnapshot snapshot;

  DateTime get month => snapshot.month;

  bool get isCurrentMonth => _isSameMonth(month, DateTime.now());

  bool get canGoNext => !isCurrentMonth;
}

class StatisticsViewModel extends AsyncNotifier<StatisticsState> {
  DateTime _selectedMonth = _monthOnly(DateTime.now());
  List<Expense> _expenses = const [];
  List<Income> _incomes = const [];

  @override
  Future<StatisticsState> build() async {
    final expenses = await ref.watch(expensesStreamProvider.future);
    final incomes = await ref.watch(incomesStreamProvider.future);
    _expenses = expenses;
    _incomes = incomes;
    return _stateFor(_selectedMonth);
  }

  void previousMonth() {
    _moveMonth(-1);
  }

  void nextMonth() {
    if (!_canGoNext) return;
    _moveMonth(1);
  }

  bool get _canGoNext {
    return _selectedMonth.isBefore(_monthOnly(DateTime.now()));
  }

  void _moveMonth(int delta) {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    if (next.isAfter(_monthOnly(DateTime.now()))) return;

    _selectedMonth = next;
    final current = state.value;
    if (current != null) {
      state = AsyncData(_stateFor(_selectedMonth));
    }
  }

  StatisticsState _stateFor(DateTime month) {
    final calculator = ref.read(calculateStatisticsProvider);
    return StatisticsState(
      snapshot: calculator(
        month: month,
        expenses: _expenses,
        incomes: _incomes,
      ),
    );
  }
}

DateTime _monthOnly(DateTime date) => DateTime(date.year, date.month);

bool _isSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}

final statisticsViewModelProvider =
    AsyncNotifierProvider<StatisticsViewModel, StatisticsState>(
      StatisticsViewModel.new,
    );
