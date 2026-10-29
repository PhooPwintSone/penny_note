/// The two built-in accounts supported by Penny Note.
///
/// The stable [code] is persisted in SQLite; the [label] is only for display.
enum AccountType {
  cash('cash', 'Cash'),
  savings('savings', 'Savings');

  const AccountType(this.code, this.label);

  final String code;
  final String label;

  static AccountType? fromCode(String code) {
    for (final type in values) {
      if (type.code == code) return type;
    }
    return null;
  }
}
