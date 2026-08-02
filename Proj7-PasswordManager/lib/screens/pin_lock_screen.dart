import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_pin_pad.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String? _errorMessage;
  bool _isError = false;

  Future<void> _onPinEntered(String pin) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.authenticateWithPin(pin);

    if (!success) {
      if (authProvider.state == AuthState.lockout) {
        setState(() {
          _isError = true;
          _errorMessage = 'Too many failed attempts. Locked for ${authProvider.lockoutRemainingSeconds}s.';
        });
      } else {
        final remaining = 5 - authProvider.failedAttempts;
        setState(() {
          _isError = true;
          _errorMessage = 'Incorrect PIN. $remaining attempt${remaining == 1 ? '' : 's'} remaining.';
        });
      }

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _isError = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    final isLockout = authProvider.state == AuthState.lockout;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
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
                  Icons.lock_person_outlined,
                  size: 36,
                  color: Colors.white,
                ),
              ).animate().scale(duration: 500.ms),

              const SizedBox(height: 24),
              Text(
                'Vault Locked',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                isLockout
                    ? 'Security Lockout Active. Try again in ${authProvider.lockoutRemainingSeconds} seconds.'
                    : 'Enter your 4-digit PIN to decrypt your vault.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: isLockout
                      ? AppTheme.errorRed
                      : isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                  fontWeight: isLockout ? FontWeight.w600 : FontWeight.normal,
                ),
              ),

              const Spacer(),

              if (!isLockout)
                CustomPinPad(
                  onPinCompleted: _onPinEntered,
                  errorMessage: _errorMessage,
                  isError: _isError,
                )
              else
                Column(
                  children: [
                    const Icon(Icons.timer_outlined, size: 64, color: AppTheme.errorRed)
                        .animate(onPlay: (controller) => controller.repeat())
                        .shake(duration: 1000.ms),
                    const SizedBox(height: 16),
                    Text(
                      '${authProvider.lockoutRemainingSeconds}s',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ],
                ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
