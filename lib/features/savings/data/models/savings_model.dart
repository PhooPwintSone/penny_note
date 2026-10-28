import '../../../../core/database/app_database.dart';
import '../../domain/entities/savings_entry.dart';

/// Data-layer representation of a savings row.
class SavingsModel {
  const SavingsModel({
    required this.id,
    required this.amountCents,
    required this.isWithdrawal,
    required this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavingsModel.fromRow(SavingsEntryRow row) {
    return SavingsModel(
      id: row.id,
      amountCents: row.amountCents,
      isWithdrawal: row.isWithdrawal,
      note: row.note,
      date: row.date,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  final int id;
  final int amountCents;
  final bool isWithdrawal;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavingsEntry toEntity() {
    return SavingsEntry(
      id: id,
      amountCents: amountCents,
      isWithdrawal: isWithdrawal,
      note: note,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
