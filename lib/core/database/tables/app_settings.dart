import 'package:drift/drift.dart';

/// A single-row table for app-wide preferences.
///
/// The fixed [id] makes the row easy to update without relying on an
/// auto-increment value. Currency is stored by its stable ISO code.
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  TextColumn get currencyCode =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('MMK'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (id = 1)',
    "CHECK (currency_code IN ('MMK', 'USD', 'CAD', 'SGD', 'THB'))",
  ];
}
