import '../../../../core/database/app_database.dart';
import '../../domain/entities/category.dart';

/// Data-layer representation of a category row.
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory CategoryModel.fromRow(CategoryRow row) {
    return CategoryModel(id: row.id, name: row.name, icon: row.icon);
  }

  final int id;
  final String name;
  final String icon;

  Category toEntity() => Category(id: id, name: name, icon: icon);
}
