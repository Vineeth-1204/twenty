import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZenithSpendApp());
}

class ZenithSpendApp extends StatelessWidget {
  const ZenithSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenith Spend - Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.googleBlue,
        scaffoldBackgroundColor: AppColors.lightBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.googleBlue,
          primary: AppColors.googleBlue,
          surface: AppColors.lightSurface,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        primaryColor: AppColors.googleBlue,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.googleBlue,
          brightness: Brightness.dark,
          primary: AppColors.googleBlue,
          surface: AppColors.darkSurface,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
