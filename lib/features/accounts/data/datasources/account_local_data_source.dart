import '../../../../core/database/daos/account_dao.dart';
import '../../domain/entities/account_type.dart';
import '../models/account_model.dart';
import '../models/financial_summary_model.dart';

/// Talks to Drift through [AccountDao] and returns data-layer models.
class AccountLocalDataSource {
  const AccountLocalDataSource(this._dao);

  final AccountDao _dao;

  Future<AccountModel?> accountByType(AccountType type) async {
    final row = await _dao.accountByCode(type.code);
    return row == null ? null : AccountModel.fromRow(row);
  }

  Stream<FinancialSummaryModel> watchSummary() {
    return _dao.watchSummary().map(FinancialSummaryModel.fromRow);
  }

  Future<FinancialSummaryModel> currentSummary() async {
    final row = await _dao.currentSummary();
    return FinancialSummaryModel.fromRow(row);
  }
}
