import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Retro pixel-art styled button
class PixelButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color bg;
  final Color fg;
  final Color shadow;
  final double fontSize;
  final Widget? icon;

  const PixelButton({
    super.key,
    required this.label,
    this.onTap,
    this.bg = AppColors.pink,
    this.fg = AppColors.navy,
    this.shadow = AppColors.magenta,
    this.fontSize = 9,
    this.icon,
  });

  const PixelButton.secondary({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.fontSize = 9,
  })  : bg = AppColors.navyLight,
        fg = AppColors.cyan,
        shadow = AppColors.cyanDark;

  const PixelButton.danger({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.fontSize = 9,
  })  : bg = AppColors.error,
        fg = Colors.white,
        shadow = const Color(0xFF8B0000);

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(
          _pressed ? 2 : 0,
          _pressed ? 2 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: widget.bg,
          border: Border(
            top:    BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 2),
            left:   BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 2),
            right:  BorderSide(color: widget.shadow, width: _pressed ? 1 : 3),
            bottom: BorderSide(color: widget.shadow, width: _pressed ? 1 : 3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: 6),
            ],
            Text(
              widget.label,
              style: AppTheme.pixelStyle(size: widget.fontSize, color: widget.fg),
            ),
          ],
        ),
      ),
    );
  }
}
