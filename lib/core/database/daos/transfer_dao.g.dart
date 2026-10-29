// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_dao.dart';

// ignore_for_file: type=lint
mixin _$TransferDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccountsTable get accounts => attachedDatabase.accounts;
  $TransfersTable get transfers => attachedDatabase.transfers;
  TransferDaoManager get managers => TransferDaoManager(this);
}

class TransferDaoManager {
  final _$TransferDaoMixin _db;
  TransferDaoManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$TransfersTableTableManager get transfers =>
      $$TransfersTableTableManager(_db.attachedDatabase, _db.transfers);
}
