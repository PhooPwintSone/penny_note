// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_dao.dart';

// ignore_for_file: type=lint
mixin _$SavingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SavingsEntriesTable get savingsEntries => attachedDatabase.savingsEntries;
  SavingsDaoManager get managers => SavingsDaoManager(this);
}

class SavingsDaoManager {
  final _$SavingsDaoMixin _db;
  SavingsDaoManager(this._db);
  $$SavingsEntriesTableTableManager get savingsEntries =>
      $$SavingsEntriesTableTableManager(
        _db.attachedDatabase,
        _db.savingsEntries,
      );
}
