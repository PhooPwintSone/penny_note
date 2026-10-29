import '../../../../core/database/daos/account_dao.dart';
import '../../domain/entities/financial_summary.dart';

/// Data-layer representation of calculated balances.
class FinancialSummaryModel {
  const FinancialSummaryModel({
    required this.totalIncomeCents,
    required this.totalExpenseCents,
    required this.cashBalanceCents,
    required this.savingsBalanceCents,
  });

  factory FinancialSummaryModel.fromRow(FinancialSummaryRow row) {
    return FinancialSummaryModel(
      totalIncomeCents: row.totalIncomeCents,
      totalExpenseCents: row.totalExpenseCents,
      cashBalanceCents: row.cashBalanceCents,
      savingsBalanceCents: row.savingsBalanceCents,
    );
  }

  final int totalIncomeCents;
  final int totalExpenseCents;
  final int cashBalanceCents;
  final int savingsBalanceCents;

  FinancialSummary toEntity() {
    return FinancialSummary(
      totalIncomeCents: totalIncomeCents,
      totalExpenseCents: totalExpenseCents,
      cashBalanceCents: cashBalanceCents,
      savingsBalanceCents: savingsBalanceCents,
    );
  }
}
