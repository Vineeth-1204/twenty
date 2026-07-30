import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/transaction.dart';

class QuickPayeeItem {
  final String title;
  final String categoryId;
  final PaymentMode defaultMode;
  final IconData icon;
  final Color color;

  const QuickPayeeItem({
    required this.title,
    required this.categoryId,
    required this.defaultMode,
    required this.icon,
    required this.color,
  });
}

class QuickPayeesBar extends StatelessWidget {
  final Function(QuickPayeeItem payee) onSelectPayee;

  const QuickPayeesBar({super.key, required this.onSelectPayee});

  static const List<QuickPayeeItem> quickPayees = [
    QuickPayeeItem(
      title: 'Tea & Coffee',
      categoryId: 'food',
      defaultMode: PaymentMode.cash,
      icon: Icons.coffee_rounded,
      color: Color(0xFFE37400),
    ),
    QuickPayeeItem(
      title: 'Auto / Taxi',
      categoryId: 'transport',
      defaultMode: PaymentMode.cash,
      icon: Icons.local_taxi_rounded,
      color: AppColors.googleBlue,
    ),
    QuickPayeeItem(
      title: 'Swiggy / Food',
      categoryId: 'food',
      defaultMode: PaymentMode.gpayUpi,
      icon: Icons.fastfood_rounded,
      color: AppColors.googleRed,
    ),
    QuickPayeeItem(
      title: 'Blinkit Groceries',
      categoryId: 'groceries',
      defaultMode: PaymentMode.gpayUpi,
      icon: Icons.shopping_cart_rounded,
      color: AppColors.googleTeal,
    ),
    QuickPayeeItem(
      title: 'Cash Withdrawal',
      categoryId: 'cash',
      defaultMode: PaymentMode.cash,
      icon: Icons.atm_rounded,
      color: Color(0xFFF57C00),
    ),
    QuickPayeeItem(
      title: 'Amazon Shopping',
      categoryId: 'shopping',
      defaultMode: PaymentMode.creditCard,
      icon: Icons.shopping_bag_rounded,
      color: AppColors.googlePurple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1-Tap Quick Payees',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.googleYellow),
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: quickPayees.length,
            itemBuilder: (context, index) {
              final payee = quickPayees[index];
              return InkWell(
                onTap: () => onSelectPayee(payee),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 76,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: payee.color.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: payee.color.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          payee.icon,
                          color: payee.color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        payee.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
