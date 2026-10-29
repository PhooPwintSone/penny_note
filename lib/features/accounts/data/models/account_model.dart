import '../../../../core/database/app_database.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';

/// Data-layer representation of a built-in account.
class AccountModel {
  const AccountModel({required this.id, required this.type});

  factory AccountModel.fromRow(AccountRow row) {
    final type = AccountType.fromCode(row.code);
    if (type == null) {
      throw StateError('Unknown account code: ${row.code}');
    }
    return AccountModel(id: row.id, type: type);
  }

  final int id;
  final AccountType type;

  Account toEntity() => Account(id: id, type: type);
}
