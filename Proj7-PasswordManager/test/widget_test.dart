import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:secure_vault/main.dart';
import 'package:secure_vault/providers/auth_provider.dart';
import 'package:secure_vault/providers/settings_provider.dart';
import 'package:secure_vault/providers/vault_provider.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App loads AuthGate without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => VaultProvider()),
        ],
        child: const SecureVaultApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
