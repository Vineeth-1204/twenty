import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/vault_provider.dart';
import 'screens/home_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'screens/setup_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VaultProvider()),
      ],
      child: const SecureVaultApp(),
    ),
  );
}

class SecureVaultApp extends StatelessWidget {
  const SecureVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'SecureVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.state) {
      case AuthState.loading:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthState.needsSetup:
        return const SetupScreen();
      case AuthState.locked:
      case AuthState.lockout:
        return const PinLockScreen();
      case AuthState.authenticated:
        return const HomeScreen();
    }
  }
}
