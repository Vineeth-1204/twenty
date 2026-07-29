import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/dune_colors.dart';

class SandBackground extends StatefulWidget {
  final Widget child;
  const SandBackground({super.key, required this.child});

  @override
  State<SandBackground> createState() => _SandBackgroundState();
}

class _SandBackgroundState extends State<SandBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: _random.nextDouble() * 2.5 + 0.5,
        speed: _random.nextDouble() * 0.08 + 0.02,
        opacity: _random.nextDouble() * 0.7 + 0.3,
        isSpice: _random.nextBool(),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: DuneColors.desertBackgroundGradient,
              ),
            ),
            CustomPaint(
              size: Size.infinite,
              painter: _SandPainter(_particles, _controller.value),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  double radius;
  double speed;
  double opacity;
  bool isSpice;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.isSpice,
  });
}

class _SandPainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;

  _SandPainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final dx = (particle.x * size.width + animationValue * particle.speed * size.width) % size.width;
      final dy = (particle.y * size.height - sin(animationValue * 2 * pi + particle.x) * 15) % size.height;

      final paint = Paint()
        ..color = particle.isSpice
            ? DuneColors.spiceOrange.withOpacity(particle.opacity)
            : DuneColors.duneGold.withOpacity(particle.opacity * 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.radius * 0.8);

      canvas.drawCircle(Offset(dx, dy), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SandPainter oldDelegate) => true;
}
