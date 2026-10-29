import 'package:drift/drift.dart';

import 'accounts.dart';

/// A single transfer between the two built-in accounts.
///
/// A transfer is stored as one row containing both the source and destination
/// account, so writing it is naturally atomic. It never appears in income or
/// expense totals.
@DataClassName('TransferRow')
class Transfers extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Money is stored in minor units (cents) to avoid floating point rounding.
  IntColumn get amountCents => integer()();

  @ReferenceName('fromTransfers')
  IntColumn get fromAccountId => integer().references(Accounts, #id)();

  @ReferenceName('toTransfers')
  IntColumn get toAccountId => integer().references(Accounts, #id)();

  TextColumn get note =>
      text().withLength(max: 200).withDefault(const Constant(''))();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
    'CHECK (amount_cents > 0)',
    'CHECK (from_account_id <> to_account_id)',
  ];
}
