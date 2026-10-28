import 'package:drift/drift.dart';

@DataClassName('SavingsEntryRow')
class SavingsEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Money is stored in minor units (cents) to avoid floating point rounding.
  IntColumn get amountCents => integer()();

  /// `false` = money added to savings, `true` = money taken out.
  BoolColumn get isWithdrawal => boolean().withDefault(const Constant(false))();

  TextColumn get note =>
      text().withLength(max: 200).withDefault(const Constant(''))();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
