import 'package:flutter/material.dart';

// Shared premium colors & styles
const Color premiumPrimary = Color(0xFF3B82F6); // Vibrant Blue
const Color premiumAccent = Color(0xFF60A5FA); // Lighter Blue
const double radiusCard = 20.0;

// --- Animated Gradient Text Logo ---
class GradientLogo extends StatefulWidget {
  final double size;
  const GradientLogo({super.key, this.size = 44});

  @override
  State<GradientLogo> createState() => _GradientLogoState();
}

class _GradientLogoState extends State<GradientLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final opacity = 0.85 + (_ctrl.value * 0.15);
        return Opacity(opacity: opacity, child: child);
      },
      child: Text(
        'hackIFM',
        style: TextStyle(
          fontSize: widget.size,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: premiumPrimary,
          shadows: [
            Shadow(
              color: premiumPrimary.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Glow Painter for background ---
class GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.2, size.height * 0.2);
    final center2 = Offset(size.width * 0.85, size.height * 0.75);

    final paint1 = Paint()
      ..color = premiumPrimary.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    final paint2 = Paint()
      ..color = premiumAccent.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    canvas.drawCircle(center, size.width * 0.3, paint1);
    canvas.drawCircle(center2, size.width * 0.25, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Neon Button ---
class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const NeonButton({super.key, required this.label, required this.onPressed});

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ani = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  @override
  void dispose() {
    _ani.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ani.forward(),
      onTapUp: (_) {
        _ani.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _ani.reverse(),
      child: AnimatedBuilder(
        animation: _ani,
        builder: (context, child) {
          final t = _ani.value;
          return Container(
            decoration: BoxDecoration(
              color: premiumPrimary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: premiumPrimary.withOpacity(0.3 + t * 0.2),
                  blurRadius: 20 + t * 8,
                  offset: Offset(0, 8 + t * 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                widget.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Neon Text Field ---
class NeonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? suffix;

  const NeonTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
                border: InputBorder.none,
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}

// --- Social Icon Button
class SocialIcon extends StatelessWidget {
  final IconData icon;
  const SocialIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: Colors.white),
    );
  }
}
