import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_pin_pad.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _step = 1; // 1 = Enter initial PIN, 2 = Confirm PIN
  String _firstPin = '';
  String? _errorMessage;
  bool _isError = false;

  void _onInitialPinEntered(String pin) {
    setState(() {
      _firstPin = pin;
      _step = 2;
      _errorMessage = null;
      _isError = false;
    });
  }

  Future<void> _onConfirmPinEntered(String confirmPin) async {
    if (_firstPin != confirmPin) {
      setState(() {
        _isError = true;
        _errorMessage = 'PINs do not match. Please try again.';
      });
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _step = 1;
            _firstPin = '';
            _errorMessage = null;
            _isError = false;
          });
        }
      });
    } else {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.setupProfile(confirmPin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // App Logo / Shield Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryNeon, AppTheme.primaryGradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNeon.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 38,
                  color: Colors.white,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 24),
              Text(
                'Welcome to SecureVault',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 8),
              Text(
                _step == 1
                    ? 'Create a 4-Digit Security PIN to encrypt your vault.'
                    : 'Confirm your 4-Digit Security PIN.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ).animate().fadeIn(delay: 300.ms),

              const Spacer(),

              CustomPinPad(
                key: ValueKey(_step),
                onPinCompleted: _step == 1 ? _onInitialPinEntered : _onConfirmPinEntered,
                errorMessage: _errorMessage,
                isError: _isError,
              ),

              const Spacer(),

              // Security notice banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 20, color: AppTheme.accentCyan),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your PIN derives a 256-bit AES encryption key. Keep it safe — it cannot be recovered if lost.',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
