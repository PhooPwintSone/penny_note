import '../entities/financial_summary.dart';
import '../repositories/account_repository.dart';

/// Returns a live financial summary for the dashboard.
class WatchFinancialSummary {
  const WatchFinancialSummary(this._repository);

  final AccountRepository _repository;

  Stream<FinancialSummary> call() => _repository.watchSummary();
}
