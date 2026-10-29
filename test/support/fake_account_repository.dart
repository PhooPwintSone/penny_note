import 'package:penny_note/features/accounts/domain/entities/account.dart';
import 'package:penny_note/features/accounts/domain/entities/account_type.dart';
import 'package:penny_note/features/accounts/domain/entities/financial_summary.dart';
import 'package:penny_note/features/accounts/domain/repositories/account_repository.dart';

/// A simple account repository for domain and widget tests.
class FakeAccountRepository implements AccountRepository {
  FakeAccountRepository({FinancialSummary? summary})
    : summary =
          summary ??
          const FinancialSummary(
            totalIncomeCents: 0,
            totalExpenseCents: 0,
            cashBalanceCents: 0,
            savingsBalanceCents: 0,
          );

  FinancialSummary summary;

  @override
  Future<Account> accountByType(AccountType type) async {
    return Account(id: type == AccountType.cash ? 1 : 2, type: type);
  }

  @override
  Future<FinancialSummary> currentSummary() async => summary;

  @override
  Stream<FinancialSummary> watchSummary() => Stream.value(summary);
}
