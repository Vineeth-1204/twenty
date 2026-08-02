import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/security_service.dart';
import '../theme/app_theme.dart';

class GeneratorScreen extends StatefulWidget {
  final bool isModal;
  final ValueChanged<String>? onSelectPassword;

  const GeneratorScreen({
    super.key,
    this.isModal = false,
    this.onSelectPassword,
  });

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  int _length = 16;
  bool _includeUpper = true;
  bool _includeLower = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _excludeSimilar = false;

  late String _generatedPassword;

  @override
  void initState() {
    super.initState();
    _regenerate();
  }

  void _regenerate() {
    setState(() {
      _generatedPassword = SecurityService.generatePassword(
        length: _length,
        includeUppercase: _includeUpper,
        includeLowercase: _includeLower,
        includeNumbers: _includeNumbers,
        includeSymbols: _includeSymbols,
        excludeSimilar: _excludeSimilar,
      );
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    HapticFeedback.mediumImpact();

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final clearSec = settings.clipboardClearSeconds;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Copied! Will auto-clear from clipboard in ${clearSec}s.',
                style: GoogleFonts.outfit(),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Schedule clipboard wipe
    Timer(Duration(seconds: clearSec), () async {
      final currentData = await Clipboard.getData(Clipboard.kTextPlain);
      if (currentData?.text == _generatedPassword) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final eval = SecurityService.evaluatePasswordStrength(_generatedPassword);
    final score = eval['score'] as double;
    final label = eval['label'] as String;

    Color strengthColor;
    if (score < 0.3) {
      strengthColor = AppTheme.errorRed;
    } else if (score < 0.6) {
      strengthColor = AppTheme.warningOrange;
    } else if (score < 0.85) {
      strengthColor = AppTheme.accentCyan;
    } else {
      strengthColor = AppTheme.successGreen;
    }

    return Scaffold(
      appBar: widget.isModal
          ? AppBar(
              title: const Text('Password Generator'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            )
          : AppBar(
              title: const Text('Generator'),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Password Display Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: strengthColor.withOpacity(0.15),
                    blurRadius: 16,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                children: [
                  SelectableText(
                    _generatedPassword,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.firaCode(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Strength bar & label
                  Row(
                    children: [
                      Text(
                        'Strength: ',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        ),
                      ),
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: strengthColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _regenerate,
                        icon: const Icon(Icons.refresh, color: AppTheme.primaryNeon),
                        tooltip: 'Regenerate',
                      ),
                      IconButton(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy, color: AppTheme.accentCyan),
                        tooltip: 'Copy',
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: score,
                      minHeight: 6,
                      backgroundColor: (isDark ? Colors.white10 : Colors.black12),
                      valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.1, duration: 400.ms),

            if (widget.isModal && widget.onSelectPassword != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  widget.onSelectPassword!(_generatedPassword);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('Use This Password'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Controls Section
            Text(
              'Customization Options',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Length Slider Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Password Length',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNeon.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_length',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNeon,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _length.toDouble(),
                    min: 8,
                    max: 64,
                    divisions: 56,
                    activeColor: AppTheme.primaryNeon,
                    onChanged: (val) {
                      setState(() {
                        _length = val.round();
                      });
                      _regenerate();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Character Sets Toggles
            _buildToggleTile('Uppercase (A-Z)', _includeUpper, (v) {
              setState(() => _includeUpper = v);
              _regenerate();
            }, isDark),
            _buildToggleTile('Lowercase (a-z)', _includeLower, (v) {
              setState(() => _includeLower = v);
              _regenerate();
            }, isDark),
            _buildToggleTile('Numbers (0-9)', _includeNumbers, (v) {
              setState(() => _includeNumbers = v);
              _regenerate();
            }, isDark),
            _buildToggleTile('Symbols (!@#\$%)', _includeSymbols, (v) {
              setState(() => _includeSymbols = v);
              _regenerate();
            }, isDark),
            _buildToggleTile('Exclude Ambiguous (1, l, I, 0, O)', _excludeSimilar, (v) {
              setState(() => _excludeSimilar = v);
              _regenerate();
            }, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(String title, bool value, ValueChanged<bool> onChanged, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        value: value,
        activeColor: AppTheme.primaryNeon,
        onChanged: onChanged,
      ),
    );
  }
}
