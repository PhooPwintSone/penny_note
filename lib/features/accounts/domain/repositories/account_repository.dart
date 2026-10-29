import '../entities/account.dart';
import '../entities/account_type.dart';
import '../entities/financial_summary.dart';

/// Contract for the built-in accounts and their calculated balances.
abstract interface class AccountRepository {
  /// Emits the current financial summary and re-emits after any ledger write.
  Stream<FinancialSummary> watchSummary();

  /// Reads the current summary once.
  Future<FinancialSummary> currentSummary();

  /// Resolves a built-in account by its stable type.
  Future<Account> accountByType(AccountType type);
}
