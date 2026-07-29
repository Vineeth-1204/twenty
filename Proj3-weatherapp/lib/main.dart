import 'package:flutter/material.dart';
import 'theme/dune_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DuneWeatherApp());
}

class DuneWeatherApp extends StatelessWidget {
  const DuneWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DUNE: Weather of Arrakis',
      debugShowCheckedModeBanner: false,
      theme: DuneTheme.theme,
      home: const HomeScreen(),
    );
  }
}
