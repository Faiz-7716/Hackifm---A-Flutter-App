import 'package:flutter/material.dart';

/// Responsive wrapper for authentication screens
/// Provides desktop split-screen layout (50% branding, 50% form)
/// and mobile full-screen layout
class ResponsiveAuthWrapper extends StatelessWidget {
  final Widget mobileContent;
  final String title;
  final String subtitle;
  final IconData icon;

  const ResponsiveAuthWrapper({
    super.key,
    required this.mobileContent,
    required this.title,
    required this.subtitle,
    this.icon = Icons.rocket_launch,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;

    if (isDesktop) {
      return _buildDesktopLayout(context, size);
    } else {
      return mobileContent;
    }
  }

  Widget _buildDesktopLayout(BuildContext context, Size size) {
    return Scaffold(
      body: Row(
        children: [
          // Left side - Branding/Image (50% width, 100% height)
          Expanded(
            flex: 1,
            child: Container(
              height: size.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                ),
              ),
              child: Stack(
                children: [
                  // Animated wave decoration
                  Positioned.fill(
                    child: CustomPaint(painter: DesktopBrandingWavePainter()),
                  ),
                  // Content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo/Icon
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(icon, size: 70, color: Colors.white),
                          ),
                          const SizedBox(height: 50),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -1,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white.withOpacity(0.95),
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 60),
                          // Feature badges
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildFeatureBadge('🚀 Internships'),
                              _buildFeatureBadge('💡 Hackathons'),
                              _buildFeatureBadge('🤖 Robotics'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side - Form Content (50% width, 100% height)
          Expanded(
            flex: 1,
            child: Container(
              height: size.height,
              color: const Color(0xFFF8FAFC),
              child: mobileContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Custom painter for desktop branding side wave decoration
class DesktopBrandingWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // First wave
    final path1 = Path();
    path1.moveTo(0, size.height * 0.2);
    path1.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.25,
      size.width * 0.5,
      size.height * 0.2,
    );
    path1.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.15,
      size.width,
      size.height * 0.2,
    );
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Second wave
    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.75,
      size.width * 0.5,
      size.height * 0.8,
    );
    path2.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.85,
      size.width,
      size.height * 0.8,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Circles decoration
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.3),
      60,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.7),
      80,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
