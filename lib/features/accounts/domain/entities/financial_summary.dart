import 'account_type.dart';

/// A consistent snapshot of the user's money, calculated from the ledger.
///
/// Transfers are deliberately excluded from [totalIncomeCents] and
/// [totalExpenseCents]; they only move money between [cashBalanceCents] and
/// [savingsBalanceCents].
class FinancialSummary {
  const FinancialSummary({
    required this.totalIncomeCents,
    required this.totalExpenseCents,
    required this.cashBalanceCents,
    required this.savingsBalanceCents,
  });

  static const empty = FinancialSummary(
    totalIncomeCents: 0,
    totalExpenseCents: 0,
    cashBalanceCents: 0,
    savingsBalanceCents: 0,
  );

  final int totalIncomeCents;
  final int totalExpenseCents;
  final int cashBalanceCents;
  final int savingsBalanceCents;

  int get totalBalanceCents => cashBalanceCents + savingsBalanceCents;

  int balanceFor(AccountType type) {
    return switch (type) {
      AccountType.cash => cashBalanceCents,
      AccountType.savings => savingsBalanceCents,
    };
  }
}
