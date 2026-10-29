import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/domain/entities/account_type.dart';

/// A transfer between Cash and Savings.
///
/// The transfer is one logical transaction containing both accounts. It never
/// counts as income or expense.
class Transfer {
  const Transfer({
    required this.id,
    required this.amountCents,
    required this.fromAccount,
    required this.toAccount,
    required this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int amountCents;
  final Account fromAccount;
  final Account toAccount;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// True when money moves from Savings back to Cash.
  bool get isWithdrawal => fromAccount.type == AccountType.savings;

  /// True when money moves from Cash into Savings.
  bool get isDeposit => fromAccount.type == AccountType.cash;

  /// The effect on the Savings balance.
  int get signedAmountCents => isWithdrawal ? -amountCents : amountCents;
}
