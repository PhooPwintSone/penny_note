import 'package:drift/drift.dart';

import 'categories.dart';

@DataClassName('ExpenseRow')
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Money is stored in minor units (cents) to avoid floating point rounding.
  IntColumn get amountCents => integer()();

  IntColumn get categoryId => integer().references(Categories, #id)();

  TextColumn get note =>
      text().withLength(max: 200).withDefault(const Constant(''))();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
