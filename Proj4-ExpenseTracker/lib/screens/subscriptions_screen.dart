import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class SubscriptionItem {
  final String title;
  final double amount;
  final String billingCycle;
  final int renewDayOfMonth;
  final IconData icon;
  final Color color;

  const SubscriptionItem({
    required this.title,
    required this.amount,
    required this.billingCycle,
    required this.renewDayOfMonth,
    required this.icon,
    required this.color,
  });
}

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  static const List<SubscriptionItem> defaultSubs = [
    SubscriptionItem(
      title: 'Netflix Premium 4K',
      amount: 649.0,
      billingCycle: 'Monthly',
      renewDayOfMonth: 5,
      icon: Icons.movie_rounded,
      color: Color(0xFFE50914),
    ),
    SubscriptionItem(
      title: 'Spotify Family Plan',
      amount: 179.0,
      billingCycle: 'Monthly',
      renewDayOfMonth: 12,
      icon: Icons.music_note_rounded,
      color: Color(0xFF1DB954),
    ),
    SubscriptionItem(
      title: 'YouTube Premium',
      amount: 129.0,
      billingCycle: 'Monthly',
      renewDayOfMonth: 18,
      icon: Icons.play_circle_fill_rounded,
      color: Color(0xFFFF0000),
    ),
    SubscriptionItem(
      title: 'Apple iCloud 200GB',
      amount: 219.0,
      billingCycle: 'Monthly',
      renewDayOfMonth: 22,
      icon: Icons.cloud_rounded,
      color: Color(0xFF007AFF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    final totalMonthlySubs = defaultSubs.fold(0.0, (sum, s) => sum + s.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Subscriptions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.googlePurple,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.googlePurple.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Subscriptions Commitment',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${currency.format(totalMonthlySubs)} / month',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Your Active Services',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ...defaultSubs.map((sub) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: sub.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(sub.icon, color: sub.color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Renews on ${sub.renewDayOfMonth}th of every month',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currency.format(sub.amount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
