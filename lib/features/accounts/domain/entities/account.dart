import 'account_type.dart';

/// A built-in account such as Cash or Savings.
class Account {
  const Account({required this.id, required this.type});

  final int id;
  final AccountType type;

  String get name => type.label;
}
