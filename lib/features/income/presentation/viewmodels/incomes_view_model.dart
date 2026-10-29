import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/income.dart';
import '../providers/income_providers.dart';

class IncomesState {
  const IncomesState(this.incomes);

  final List<Income> incomes;

  bool get isEmpty => incomes.isEmpty;
}

class IncomesViewModel extends AsyncNotifier<IncomesState> {
  @override
  Future<IncomesState> build() async {
    final incomes = await ref.watch(incomesStreamProvider.future);
    return IncomesState(incomes);
  }

  /// Deletes an income entry. The list refreshes through the Drift stream;
  /// errors are rethrown so the screen can show a message.
  Future<void> deleteIncome(int id) {
    return ref.read(deleteIncomeUseCaseProvider)(id);
  }
}

final incomesViewModelProvider =
    AsyncNotifierProvider<IncomesViewModel, IncomesState>(IncomesViewModel.new);
