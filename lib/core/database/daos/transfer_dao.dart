import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/accounts.dart';
import '../tables/transfers.dart';

part 'transfer_dao.g.dart';

/// A transfer joined with both of its accounts.
class TransferWithAccountsRow {
  const TransferWithAccountsRow({
    required this.transfer,
    required this.fromAccount,
    required this.toAccount,
  });

  final TransferRow transfer;
  final AccountRow fromAccount;
  final AccountRow toAccount;
}

@DriftAccessor(tables: [Transfers, Accounts])
class TransferDao extends DatabaseAccessor<AppDatabase>
    with _$TransferDaoMixin {
  TransferDao(super.db);

  Stream<List<TransferWithAccountsRow>> watchAll() {
    final fromAccount = alias(accounts, 'from_account');
    final toAccount = alias(accounts, 'to_account');
    final query =
        select(transfers).join([
          innerJoin(
            fromAccount,
            fromAccount.id.equalsExp(transfers.fromAccountId),
          ),
          innerJoin(toAccount, toAccount.id.equalsExp(transfers.toAccountId)),
        ])..orderBy([
          OrderingTerm.desc(transfers.date),
          OrderingTerm.desc(transfers.id),
        ]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => TransferWithAccountsRow(
              transfer: row.readTable(transfers),
              fromAccount: row.readTable(fromAccount),
              toAccount: row.readTable(toAccount),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<int> insertTransfer(TransfersCompanion transfer) {
    return into(transfers).insert(transfer);
  }

  Future<bool> updateTransfer(int id, TransfersCompanion transfer) async {
    final updated = await (update(
      transfers,
    )..where((row) => row.id.equals(id))).write(transfer);
    return updated > 0;
  }

  Future<bool> deleteTransfer(int id) async {
    final deleted = await (delete(
      transfers,
    )..where((row) => row.id.equals(id))).go();
    return deleted > 0;
  }

  Future<TransferWithAccountsRow?> findById(int id) async {
    final transfer = await (select(
      transfers,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (transfer == null) return null;

    final fromAccount = await (select(
      accounts,
    )..where((row) => row.id.equals(transfer.fromAccountId))).getSingle();
    final toAccount = await (select(
      accounts,
    )..where((row) => row.id.equals(transfer.toAccountId))).getSingle();

    return TransferWithAccountsRow(
      transfer: transfer,
      fromAccount: fromAccount,
      toAccount: toAccount,
    );
  }
}
