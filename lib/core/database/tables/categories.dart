import 'package:drift/drift.dart';

@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 40).unique()();

  /// Stable icon key resolved by `categoryIconFor` in the presentation layer.
  TextColumn get icon => text().withLength(min: 1, max: 40)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
