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
  'school': Icons.school_rounded,
  'work': Icons.work_rounded,
  'payments': Icons.payments_rounded,
  'business_center': Icons.business_center_rounded,
  'card_giftcard': Icons.card_giftcard_rounded,
  'trending_up': Icons.trending_up_rounded,
  'account_balance': Icons.account_balance_rounded,
  'pets': Icons.pets_rounded,
  'fitness_center': Icons.fitness_center_rounded,
  'movie': Icons.movie_rounded,
  'phone_android': Icons.phone_android_rounded,
  'flight': Icons.flight_rounded,
  'savings': Icons.savings_rounded,
  'child_care': Icons.child_care_rounded,
  'local_grocery_store': Icons.local_grocery_store_rounded,
  'medical_services': Icons.medical_services_rounded,
  'sports_esports': Icons.sports_esports_rounded,
  'celebration': Icons.celebration_rounded,
  'checkroom': Icons.checkroom_rounded,
};

/// Icons offered by the category editor, with friendly labels.
const List<({String key, String label})> categoryIconOptions = [
  (key: 'restaurant', label: 'Food'),
  (key: 'local_cafe', label: 'Coffee'),
  (key: 'directions_bus', label: 'Transport'),
  (key: 'shopping_bag', label: 'Shopping'),
  (key: 'local_grocery_store', label: 'Groceries'),
  (key: 'receipt_long', label: 'Bills'),
  (key: 'favorite', label: 'Health'),
  (key: 'medical_services', label: 'Medical'),
  (key: 'home', label: 'Home'),
  (key: 'school', label: 'School'),
  (key: 'work', label: 'Work'),
  (key: 'payments', label: 'Salary'),
  (key: 'business_center', label: 'Business'),
  (key: 'card_giftcard', label: 'Gift'),
  (key: 'trending_up', label: 'Interest'),
  (key: 'account_balance', label: 'Bank'),
  (key: 'phone_android', label: 'Phone'),
  (key: 'fitness_center', label: 'Fitness'),
  (key: 'sports_esports', label: 'Games'),
  (key: 'movie', label: 'Movies'),
  (key: 'pets', label: 'Pets'),
  (key: 'child_care', label: 'Family'),
  (key: 'flight', label: 'Travel'),
  (key: 'checkroom', label: 'Clothes'),
  (key: 'celebration', label: 'Celebration'),
  (key: 'savings', label: 'Savings'),
  (key: 'category', label: 'Other'),
];

IconData categoryIconFor(String key) => _icons[key] ?? Icons.category_rounded;
