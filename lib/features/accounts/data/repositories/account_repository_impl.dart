import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/entities/financial_summary.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._localDataSource);

  final AccountLocalDataSource _localDataSource;

  @override
  Future<Account> accountByType(AccountType type) async {
    try {
      final model = await _localDataSource.accountByType(type);
      if (model == null) {
        throw DatabaseFailure('The ${type.label} account is unavailable.');
      }
      return model.toEntity();
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const DatabaseFailure('Could not read your accounts.');
    }
  }

  @override
  Future<FinancialSummary> currentSummary() async {
    try {
      final model = await _localDataSource.currentSummary();
      return model.toEntity();
    } catch (_) {
      throw const DatabaseFailure('Could not calculate your balances.');
    }
  }

  @override
  Stream<FinancialSummary> watchSummary() {
    return _localDataSource
        .watchSummary()
        .map((model) => model.toEntity())
        .handleError((Object _, StackTrace _) {
          throw const DatabaseFailure('Could not calculate your balances.');
        });
  }
}
