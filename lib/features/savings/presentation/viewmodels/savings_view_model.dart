import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../accounts/presentation/providers/account_providers.dart';
import '../../domain/entities/transfer.dart';
import '../providers/savings_providers.dart';

class SavingsState {
  const SavingsState({required this.transfers, required this.totalCents});

  final List<Transfer> transfers;

  /// The current Savings balance, calculated by the shared account summary.
  final int totalCents;

  bool get isEmpty => transfers.isEmpty;
}

class SavingsViewModel extends AsyncNotifier<SavingsState> {
  @override
  Future<SavingsState> build() async {
    final transfers = await ref.watch(transfersStreamProvider.future);
    final summary = await ref.watch(financialSummaryStreamProvider.future);
    return SavingsState(
      transfers: transfers,
      totalCents: summary.savingsBalanceCents,
    );
  }

  Future<void> deleteTransfer(int id) {
    return ref.read(deleteTransferUseCaseProvider)(id);
  }
}

final savingsViewModelProvider =
    AsyncNotifierProvider<SavingsViewModel, SavingsState>(SavingsViewModel.new);
