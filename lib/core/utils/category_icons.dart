import 'package:flutter/material.dart';

/// Maps the icon keys stored in the `categories` table to Material icons.
///
/// Keep the keys stable: they are persisted in SQLite and a rename would leave
/// existing categories without an icon.
const Map<String, IconData> _icons = {
  'restaurant': Icons.restaurant_rounded,
  'directions_bus': Icons.directions_bus_rounded,
  'shopping_bag': Icons.shopping_bag_rounded,
  'receipt_long': Icons.receipt_long_rounded,
  'favorite': Icons.favorite_rounded,
  'local_cafe': Icons.local_cafe_rounded,
  'home': Icons.home_rounded,
  'category': Icons.category_rounded,
};

IconData categoryIconFor(String key) => _icons[key] ?? Icons.category_rounded;
