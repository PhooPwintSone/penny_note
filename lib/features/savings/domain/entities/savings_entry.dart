/// A deposit into or withdrawal from the savings ledger.
///
/// Money is kept as integer cents so totals never suffer from floating point
/// rounding. The savings balance is the sum of deposits minus withdrawals.
class SavingsEntry {
  const SavingsEntry({
    required this.id,
    required this.amountCents,
    required this.isWithdrawal,
    required this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int amountCents;
  final bool isWithdrawal;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get signedAmountCents => isWithdrawal ? -amountCents : amountCents;
}
