import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final Color lightBgColor;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.lightBgColor,
  });

  static const List<CategoryItem> defaultCategories = [
    CategoryItem(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFE37400),
      lightBgColor: Color(0xFFFEF3E6),
    ),
    CategoryItem(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.shopping_basket_rounded,
      color: AppColors.googleTeal,
      lightBgColor: AppColors.googleTealLight,
    ),
    CategoryItem(
      id: 'transport',
      name: 'Transportation',
      icon: Icons.directions_car_rounded,
      color: AppColors.googleBlue,
      lightBgColor: AppColors.googleBlueLight,
    ),
    CategoryItem(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.local_mall_rounded,
      color: AppColors.googlePurple,
      lightBgColor: AppColors.googlePurpleLight,
    ),
    CategoryItem(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFD93025),
      lightBgColor: AppColors.googleRedLight,
    ),
    CategoryItem(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_creation_rounded,
      color: Color(0xFFC2185B),
      lightBgColor: Color(0xFFFCE4EC),
    ),
    CategoryItem(
      id: 'cash',
      name: 'Cash Expenses',
      icon: Icons.payments_rounded,
      color: Color(0xFFF57C00),
      lightBgColor: Color(0xFFFFF3E0),
    ),
    CategoryItem(
      id: 'subscriptions',
      name: 'Subscriptions',
      icon: Icons.subscriptions_rounded,
      color: Color(0xFF512DA8),
      lightBgColor: Color(0xFFEDE7F6),
    ),
    CategoryItem(
      id: 'salary',
      name: 'Income & Salary',
      icon: Icons.attach_money_rounded,
      color: AppColors.googleTeal,
      lightBgColor: AppColors.googleTealLight,
    ),
    CategoryItem(
      id: 'misc',
      name: 'Miscellaneous',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF5F6368),
      lightBgColor: Color(0xFFF1F3F4),
    ),
  ];

  static CategoryItem getById(String id) {
    return defaultCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => defaultCategories.last,
    );
  }
}
