import '../../../../core/database/app_database.dart';
import '../../domain/entities/income_category.dart';

/// Data-layer representation of an income-category row.
class IncomeCategoryModel {
  const IncomeCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory IncomeCategoryModel.fromRow(IncomeCategoryRow row) {
    return IncomeCategoryModel(id: row.id, name: row.name, icon: row.icon);
  }

  final int id;
  final String name;
  final String icon;

  IncomeCategory toEntity() => IncomeCategory(id: id, name: name, icon: icon);
}
