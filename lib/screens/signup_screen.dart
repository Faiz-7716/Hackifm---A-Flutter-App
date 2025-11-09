import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _agreeToPolicy = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1024;
    final maxWidth = isSmallScreen
        ? double.infinity
        : (isMediumScreen ? 500.0 : 450.0);
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
    final contentPadding = isSmallScreen ? 24.0 : 32.0;
    final titleFontSize = isSmallScreen ? 28.0 : 32.0;
    final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
    final waveSize = isSmallScreen ? 120.0 : 140.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20.0,
            ),
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Pink wave decorations at the top
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CustomPaint(
                      size: Size(waveSize, waveSize),
                      painter: TopRightWavePainterSignup(),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: EdgeInsets.all(contentPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: isSmallScreen ? 10 : 20),

                        // Motivational Quote
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5DADE2), Color(0xFF3498DB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.white,
                                size: isSmallScreen ? 24 : 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Ideas - Future - Mastery',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 15 : 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 32),

                        // Title
                        Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3142),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Hello! let's join with us",
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 32),

                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          hint: 'Email',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        _buildTextField(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password field
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hint: 'Confirm Password',
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),

                        // Privacy policy checkbox
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _agreeToPolicy,
                                onChanged: (value) {
                                  setState(() {
                                    _agreeToPolicy = value ?? false;
                                  });
                                },
                                activeColor: const Color(0xFF3498DB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'I agree with privacy policy',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 24),

                        // Pink wave section with sign up button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              // Wave background
                              CustomPaint(
                                size: Size(
                                  double.infinity,
                                  isSmallScreen ? 150 : 180,
                                ),
                                painter: SignupWavePainter(),
                              ),

                              // Sign up button
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 30.0 : 40.0,
                                  horizontal: contentPadding,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: isSmallScreen ? 48 : 56,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/home',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF2D3142),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    child: Text(
                                      'SIGN UP',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 12 : 16),

                        // Sign in link
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'You already have an account? ',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Sign in',
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: const Color(0xFF3498DB),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// Top right wave decoration for signup
class TopRightWavePainterSignup extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3498DB).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width * 0.3, 0);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.4,
      size.width,
      size.height * 0.7,
    );
    path.close();

    canvas.drawPath(path, paint);

    // Add a second layer for depth
    final paint2 = Paint()
      ..color = const Color(0xFF5DADE2).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(size.width, 0);
    path2.lineTo(size.width * 0.5, 0);
    path2.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.3,
      size.width,
      size.height * 0.5,
    );
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Wave background for signup button section
class SignupWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3498DB), Color(0xFF5DADE2)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.3);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.25,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.3,
      size.width,
      size.height * 0.2,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave layer
    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF2874A6).withOpacity(0.6),
          const Color(0xFF5DADE2).withOpacity(0.6),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path2 = Path();
    path2.moveTo(0, size.height * 0.4);

    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.35,
      size.width * 0.6,
      size.height * 0.4,
    );

    path2.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.43,
      size.width,
      size.height * 0.35,
    );

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
