import 'package:drift/drift.dart';

import 'income_categories.dart';

/// A single income entry.
///
/// Money is stored in minor units (cents) to avoid floating point rounding.
@DataClassName('IncomeRow')
class Incomes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get amountCents => integer()();

  IntColumn get categoryId => integer().references(IncomeCategories, #id)();

  TextColumn get note =>
      text().withLength(max: 200).withDefault(const Constant(''))();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
