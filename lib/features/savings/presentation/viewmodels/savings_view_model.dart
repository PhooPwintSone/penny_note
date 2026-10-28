import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/savings_entry.dart';
import '../providers/savings_providers.dart';

class SavingsState {
  const SavingsState({required this.entries, required this.totalCents});

  final List<SavingsEntry> entries;
  final int totalCents;

  bool get isEmpty => entries.isEmpty;
}

class SavingsViewModel extends AsyncNotifier<SavingsState> {
  @override
  Future<SavingsState> build() async {
    final entries = await ref.watch(savingsStreamProvider.future);
    final total = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.signedAmountCents,
    );
    return SavingsState(entries: entries, totalCents: total);
  }

  Future<void> deleteEntry(int id) {
    return ref.read(deleteSavingsUseCaseProvider)(id);
  }
}

final savingsViewModelProvider =
    AsyncNotifierProvider<SavingsViewModel, SavingsState>(SavingsViewModel.new);
