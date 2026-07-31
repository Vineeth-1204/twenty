import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// CRT scanlines effect painted over the whole screen
class ScanlinesOverlay extends StatelessWidget {
  const ScanlinesOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ScanlinesPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.10)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.35),
        ],
        stops: const [0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  @override
  bool shouldRepaint(_ScanlinesPainter oldDelegate) => false;
}

/// Flickering pixel corner star
class CornerDeco extends StatefulWidget {
  final Alignment alignment;
  const CornerDeco({super.key, required this.alignment});

  @override
  State<CornerDeco> createState() => _CornerDecoState();
}

class _CornerDecoState extends State<CornerDeco>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _rot;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _rot = Tween(begin: 0.0, end: 0.35).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform.rotate(
            angle: _rot.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Text(
                '✦',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.pink,
                  shadows: [
                    Shadow(
                      color: AppColors.pink.withValues(alpha: 0.8),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
