import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/accounts.dart';
import '../tables/expenses.dart';
import '../tables/incomes.dart';
import '../tables/transfers.dart';

part 'account_dao.g.dart';

/// A single row containing every calculated total needed by the dashboard and
/// the domain validation use cases.
class FinancialSummaryRow {
  const FinancialSummaryRow({
    required this.totalIncomeCents,
    required this.totalExpenseCents,
    required this.cashBalanceCents,
    required this.savingsBalanceCents,
  });

  final int totalIncomeCents;
  final int totalExpenseCents;
  final int cashBalanceCents;
  final int savingsBalanceCents;
}

@DriftAccessor(tables: [Accounts, Incomes, Expenses, Transfers])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  AccountDao(super.db);

  Stream<List<AccountRow>> watchAccounts() {
    final query = select(accounts)
      ..orderBy([(row) => OrderingTerm.asc(row.id)]);
    return query.watch();
  }

  Future<AccountRow?> accountByCode(String code) {
    return (select(
      accounts,
    )..where((row) => row.code.equals(code))).getSingleOrNull();
  }

  /// Calculates all balances from persisted ledger rows.
  ///
  /// Cash starts with income minus expenses, then transfers into Cash are
  /// added and transfers out of Cash are subtracted. Savings is only affected
  /// by transfers. This keeps stored balances impossible to drift away from the
  /// transaction history.
  Stream<FinancialSummaryRow> watchSummary() {
    return customSelect(
      '''
      SELECT
        (SELECT COALESCE(SUM(amount_cents), 0) FROM incomes)
          AS total_income_cents,
        (SELECT COALESCE(SUM(amount_cents), 0) FROM expenses)
          AS total_expense_cents,
        (
          (SELECT COALESCE(SUM(amount_cents), 0) FROM incomes)
          - (SELECT COALESCE(SUM(amount_cents), 0) FROM expenses)
          + (
            SELECT COALESCE(SUM(t.amount_cents), 0)
            FROM transfers t
            INNER JOIN accounts a ON a.id = t.to_account_id
            WHERE a.code = 'cash'
          )
          - (
            SELECT COALESCE(SUM(t.amount_cents), 0)
            FROM transfers t
            INNER JOIN accounts a ON a.id = t.from_account_id
            WHERE a.code = 'cash'
          )
        ) AS cash_balance_cents,
        (
          (
            SELECT COALESCE(SUM(t.amount_cents), 0)
            FROM transfers t
            INNER JOIN accounts a ON a.id = t.to_account_id
            WHERE a.code = 'savings'
          )
          - (
            SELECT COALESCE(SUM(t.amount_cents), 0)
            FROM transfers t
            INNER JOIN accounts a ON a.id = t.from_account_id
            WHERE a.code = 'savings'
          )
        ) AS savings_balance_cents
      ''',
      readsFrom: {incomes, expenses, transfers, accounts},
    ).watchSingle().map(
      (row) => FinancialSummaryRow(
        totalIncomeCents: row.read<int>('total_income_cents'),
        totalExpenseCents: row.read<int>('total_expense_cents'),
        cashBalanceCents: row.read<int>('cash_balance_cents'),
        savingsBalanceCents: row.read<int>('savings_balance_cents'),
      ),
    );
  }

  Future<FinancialSummaryRow> currentSummary() => watchSummary().first;
}
