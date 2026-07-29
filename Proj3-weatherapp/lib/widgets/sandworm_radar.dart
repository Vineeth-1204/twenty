import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/dune_colors.dart';

class SandwormRadar extends StatefulWidget {
  final double threatLevel; // 0 - 10
  const SandwormRadar({super.key, required this.threatLevel});

  @override
  State<SandwormRadar> createState() => _SandwormRadarState();
}

class _SandwormRadarState extends State<SandwormRadar> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DuneColors.cardBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.threatLevel > 7.0 ? DuneColors.stormRed : DuneColors.glassBorder,
          width: widget.threatLevel > 7.0 ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.radar, color: DuneColors.spiceOrange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "THUMPER & SEISMIC RADAR",
                    style: GoogleFonts.rajdhani(
                      color: DuneColors.spiceOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Text(
                widget.threatLevel > 7.0 ? "SHAI-HULUD NEARBY!" : "SAND VIBRATION LOW",
                style: GoogleFonts.rajdhani(
                  color: widget.threatLevel > 7.0 ? DuneColors.stormRed : DuneColors.calmGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _radarController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _RadarPainter(_radarController.value, widget.threatLevel),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double animationValue;
  final double threat;

  _RadarPainter(this.animationValue, this.threat);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width / 2, size.height / 2) - 10;

    final gridPaint = Paint()
      ..color = DuneColors.glassBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw concentric radar circles
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, maxRadius * (i / 3), gridPaint);
    }
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), gridPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), gridPaint);

    // Radar scan beam line
    final angle = animationValue * 2 * pi;
    final lineEnd = Offset(
      center.dx + maxRadius * cos(angle),
      center.dy + maxRadius * sin(angle),
    );

    final beamPaint = Paint()
      ..color = threat > 7.0 ? DuneColors.stormRed : DuneColors.spiceOrange
      ..strokeWidth = 2.0;

    canvas.drawLine(center, lineEnd, beamPaint);

    // Draw pulsating thumper wave
    final pulseRadius = maxRadius * (animationValue % 1.0);
    final pulsePaint = Paint()
      ..color = (threat > 7.0 ? DuneColors.stormRed : DuneColors.spiceOrange).withOpacity(1.0 - animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, pulseRadius, pulsePaint);

    // Draw worm blip if threat is high
    if (threat > 4.0) {
      final blipAngle = 1.2;
      final blipDistance = maxRadius * 0.6;
      final blipPos = Offset(center.dx + blipDistance * cos(blipAngle), center.dy + blipDistance * sin(blipAngle));

      final blipPaint = Paint()
        ..color = DuneColors.stormRed
        ..style = PaintingStyle.fill;

      canvas.drawCircle(blipPos, 6, blipPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => true;
}
