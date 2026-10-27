import '../../../../core/database/daos/expense_dao.dart';
import '../../../categories/data/models/category_model.dart';
import '../../domain/entities/expense.dart';

/// Data-layer representation of an expense joined with its category.
class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.amountCents,
    required this.category,
    required this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromRow(ExpenseWithCategoryRow row) {
    return ExpenseModel(
      id: row.expense.id,
      amountCents: row.expense.amountCents,
      category: CategoryModel.fromRow(row.category),
      note: row.expense.note,
      date: row.expense.date,
      createdAt: row.expense.createdAt,
      updatedAt: row.expense.updatedAt,
    );
  }

  final int id;
  final int amountCents;
  final CategoryModel category;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense toEntity() {
    return Expense(
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
