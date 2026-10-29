import 'package:drift/drift.dart';

/// Categories used by income entries.
///
/// Kept separate from expense categories so the two journals can use names
/// like "Other" or "Gifts" without sharing a taxonomy.
@DataClassName('IncomeCategoryRow')
class IncomeCategories extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 40).unique()();

  /// Stable icon key resolved by `categoryIconFor` in the presentation layer.
  TextColumn get icon => text().withLength(min: 1, max: 40)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
