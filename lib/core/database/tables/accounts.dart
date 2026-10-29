import 'package:drift/drift.dart';

/// The two built-in accounts. Rows are seeded with stable [code] values so the
/// app can resolve Cash and Savings without relying on auto-increment ids.
@DataClassName('AccountRow')
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Stable identifier: `cash` or `savings`.
  TextColumn get code => text().withLength(min: 1, max: 32).unique()();

  /// Display name shown in the UI.
  TextColumn get name => text().withLength(min: 1, max: 64)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => ["CHECK (code IN ('cash', 'savings'))"];
}
