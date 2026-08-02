import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CustomPinPad extends StatefulWidget {
  final int pinLength;
  final ValueChanged<String> onPinCompleted;
  final ValueChanged<String>? onPinChanged;
  final String? errorMessage;
  final bool isError;

  const CustomPinPad({
    super.key,
    this.pinLength = 4,
    required this.onPinCompleted,
    this.onPinChanged,
    this.errorMessage,
    this.isError = false,
  });

  @override
  State<CustomPinPad> createState() => _CustomPinPadState();
}

class _CustomPinPadState extends State<CustomPinPad> {
  String _enteredPin = '';

  void _onKeyPress(String digit) {
    if (_enteredPin.length < widget.pinLength) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredPin += digit;
      });
      widget.onPinChanged?.call(_enteredPin);

      if (_enteredPin.length == widget.pinLength) {
        widget.onPinCompleted(_enteredPin);
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
      widget.onPinChanged?.call(_enteredPin);
    }
  }

  void resetPin() {
    setState(() {
      _enteredPin = '';
    });
    widget.onPinChanged?.call(_enteredPin);
  }

  @override
  void didUpdateWidget(covariant CustomPinPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isError && !oldWidget.isError) {
      // Clear PIN on error
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) resetPin();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PIN Dots Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.pinLength, (index) {
            final isFilled = index < _enteredPin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled
                    ? widget.isError
                        ? AppTheme.errorRed
                        : AppTheme.primaryNeon
                    : Colors.transparent,
                border: Border.all(
                  color: widget.isError
                      ? AppTheme.errorRed
                      : isFilled
                          ? AppTheme.primaryNeon
                          : isDark
                              ? AppTheme.darkCardBorder
                              : AppTheme.lightCardBorder,
                  width: 2,
                ),
                boxShadow: isFilled
                    ? [
                        BoxShadow(
                          color: (widget.isError ? AppTheme.errorRed : AppTheme.primaryNeon).withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ).animate(target: widget.isError ? 1 : 0).shake(duration: 400.ms, hz: 4),

        if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            widget.errorMessage!,
            style: GoogleFonts.outfit(
              color: AppTheme.errorRed,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(),
        ],

        const SizedBox(height: 36),

        // Keypad Grid
        SizedBox(
          width: 280,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              for (int i = 1; i <= 9; i++) _buildKeyButton(i.toString(), isDark),
              const SizedBox.shrink(),
              _buildKeyButton('0', isDark),
              _buildBackspaceButton(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyButton(String val, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(val),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
            border: Border.all(
              color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
            ),
          ),
          child: Center(
            child: Text(
              val,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onBackspace,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 26,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
