import 'dart:math' as math;
import 'package:flutter/material.dart';

/// AnimatedLogo: a self-contained, dependency-free animated logo widget.
/// Features:
/// - Image or text fallback
/// - Breathing scale, slow rotation
/// - Radial glow and animated ring sweep
/// - Tiny orbiting particles
class AnimatedLogo extends StatefulWidget {
  final double size;
  final String? imageAssetPath; // e.g. 'assets/logo.png'
  final Color primaryColor;

  const AnimatedLogo({
    super.key,
    this.size = 180,
    this.imageAssetPath,
    this.primaryColor = const Color(0xFF3498DB),
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late final AnimationController _breathCtrl;
  late final AnimationController _ringCtrl;
  late final AnimationController _particleCtrl;

  @override
  void initState() {
    super.initState();

    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _ringCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathCtrl, _ringCtrl, _particleCtrl]),
        builder: (context, child) {
          final breath = 1.0 + (_breathCtrl.value * 0.06); // subtle scale
          final ringProgress = _ringCtrl.value;
          final particlePhase = _particleCtrl.value;

          return CustomPaint(
            painter: _LogoBackgroundPainter(
              glowColor: widget.primaryColor,
              ringProgress: ringProgress,
              particlePhase: particlePhase,
            ),
            child: Transform.scale(
              scale: breath,
              child: Container(
                width: size * 0.78,
                height: size * 0.78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.28),
                      blurRadius: 40,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: widget.imageAssetPath != null
                      ? Image.asset(widget.imageAssetPath!, fit: BoxFit.contain)
                      : Center(
                          child: Text(
                            'H',
                            style: TextStyle(
                              fontSize: size * 0.36,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LogoBackgroundPainter extends CustomPainter {
  final Color glowColor;
  final double ringProgress; // 0.0 - 1.0
  final double particlePhase; // 0.0 - 1.0

  _LogoBackgroundPainter({
    required this.glowColor,
    required this.ringProgress,
    required this.particlePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.5;

    // Soft radial glow behind the logo
    final glowPaint = Paint()
      ..color = glowColor.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, radius * 1.1, glowPaint);

    // Animated ring (arc) around the logo
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round
      ..color = glowColor.withOpacity(0.6);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.92),
      -math.pi / 2,
      2 * math.pi * ringProgress,
      false,
      ringPaint,
    );

    // Subtle orbiting particles
    final particlePaint = Paint()..color = Colors.white.withOpacity(0.06);
    final count = 10;
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi + particlePhase * 2 * math.pi;
      final px = center.dx + math.cos(angle) * radius * 0.95;
      final py =
          center.dy +
          math.sin(angle) *
              radius *
              0.95 *
              0.8 *
              (1 + 0.05 * math.sin(i + particlePhase * 4));
      final pr = 1.5 + (i % 3) * 0.8;
      canvas.drawCircle(Offset(px, py), pr, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LogoBackgroundPainter oldDelegate) {
    return oldDelegate.ringProgress != ringProgress ||
        oldDelegate.particlePhase != particlePhase ||
        oldDelegate.glowColor != glowColor;
  }
}
