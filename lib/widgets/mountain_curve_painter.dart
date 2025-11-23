import 'package:flutter/material.dart';

/// Custom painter that creates a mountain-like curved border
class MountainCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Start from top left
    path.moveTo(0, 0);

    // Create clean symmetrical wave with 2 bumps
    // First bump down
    path.quadraticBezierTo(width * 0.25, height * 0.8, width * 0.5, 0);

    // Second bump down (mirror of first)
    path.quadraticBezierTo(width * 0.75, height * 0.8, width, 0);

    // Close the path by drawing to bottom corners
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
