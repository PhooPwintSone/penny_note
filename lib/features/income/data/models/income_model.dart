import '../../../../core/database/daos/income_dao.dart';
import '../../domain/entities/income.dart';
import 'income_category_model.dart';

/// Data-layer representation of an income entry joined with its category.
class IncomeModel {
  const IncomeModel({
    required this.id,
    required this.amountCents,
    required this.category,
    required this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncomeModel.fromRow(IncomeWithCategoryRow row) {
    return IncomeModel(
      id: row.income.id,
      amountCents: row.income.amountCents,
      category: IncomeCategoryModel.fromRow(row.category),
      note: row.income.note,
      date: row.income.date,
      createdAt: row.income.createdAt,
      updatedAt: row.income.updatedAt,
    );
  }

  final int id;
  final int amountCents;
  final IncomeCategoryModel category;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Income toEntity() {
    return Income(
      id: id,
      amountCents: amountCents,
      category: category.toEntity(),
      note: note,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
