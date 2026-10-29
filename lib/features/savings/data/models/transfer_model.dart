import '../../../../core/database/daos/transfer_dao.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../domain/entities/transfer.dart';

/// Data-layer representation of a transfer joined with both accounts.
class TransferModel {
  const TransferModel({
    required this.id,
    required this.amountCents,
    required this.fromAccount,
    required this.toAccount,
    required this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransferModel.fromRow(TransferWithAccountsRow row) {
    return TransferModel(
      id: row.transfer.id,
      amountCents: row.transfer.amountCents,
      fromAccount: AccountModel.fromRow(row.fromAccount),
      toAccount: AccountModel.fromRow(row.toAccount),
      note: row.transfer.note,
      date: row.transfer.date,
      createdAt: row.transfer.createdAt,
      updatedAt: row.transfer.updatedAt,
    );
  }

  final int id;
  final int amountCents;
  final AccountModel fromAccount;
  final AccountModel toAccount;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transfer toEntity() {
    return Transfer(
      id: id,
      amountCents: amountCents,
      fromAccount: fromAccount.toEntity(),
      toAccount: toAccount.toEntity(),
      note: note,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
