import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Horizontally scrolling ticker-tape marquee
class TickerTape extends StatefulWidget {
  final List<String> messages;
  const TickerTape({super.key, required this.messages});

  @override
  State<TickerTape> createState() => _TickerTapeState();
}

class _TickerTapeState extends State<TickerTape>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullText =
        widget.messages.join('          ') + '          ';

    return Container(
      height: 26,
      color: AppColors.pink,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return CustomPaint(
              painter: _TickerPainter(
                text: fullText,
                progress: _ctrl.value,
                style: AppTheme.pixelStyle(size: 7, color: AppColors.navy),
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _TickerPainter extends CustomPainter {
  final String text;
  final double progress;
  final TextStyle style;

  _TickerPainter({
    required this.text,
    required this.progress,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final span = TextSpan(text: '$text$text', style: style);
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity);

    final totalWidth = tp.width;
    final halfWidth = totalWidth / 2;
    final offset = -progress * halfWidth;

    // Draw twice to create seamless loop
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final dy = (size.height - tp.height) / 2;

    // Draw at current offset and offset + halfWidth for seamless wrap
    tp.paint(canvas, Offset(offset, dy));
    tp.paint(canvas, Offset(offset + halfWidth, dy));

    canvas.restore();
  }

  @override
  bool shouldRepaint(_TickerPainter old) =>
      old.progress != progress || old.text != text;
}
