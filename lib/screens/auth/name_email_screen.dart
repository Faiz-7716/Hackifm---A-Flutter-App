import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'otp_verification_screen.dart';
import '../../utils/auth_colors.dart';
import '../../widgets/mountain_curve_painter.dart';

class NameEmailScreen extends StatefulWidget {
  const NameEmailScreen({Key? key}) : super(key: key);

  @override
  State<NameEmailScreen> createState() => _NameEmailScreenState();
}

class _NameEmailScreenState extends State<NameEmailScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _isCheckingEmail = false;
  String? _emailMessage;
  bool? _emailAvailable;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailAvailability(String email) async {
    if (email.isEmpty || !_isValidEmail(email)) {
      setState(() {
        _emailMessage = null;
        _emailAvailable = null;
      });
      return;
    }

    setState(() {
      _isCheckingEmail = true;
      _emailMessage = null;
    });

    try {
      final result = await _apiService.checkEmailAvailability(email);
      setState(() {
        _emailAvailable = result['email_available'] ?? false;
        _emailMessage = result['message'];
      });
    } catch (e) {
      setState(() {
        _emailMessage = 'Error checking email';
        _emailAvailable = null;
      });
    } finally {
      setState(() {
        _isCheckingEmail = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    // More lenient email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9][a-zA-Z0-9._+-]*@[a-zA-Z0-9][a-zA-Z0-9.-]*\.[a-zA-Z]{2,}$',
    );
    return email.isNotEmpty && emailRegex.hasMatch(email.trim());
  }

  Future<void> _sendOTP() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid name (at least 2 characters)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_emailAvailable == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This email is already registered. Try Login.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.sendSignupOTP(
        name: name,
        email: email.toLowerCase(),
      );

      if (result['success']) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OTPVerificationScreen(name: name, email: email.toLowerCase()),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to send OTP'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Blue header section with logo
          Container(
            width: double.infinity,
            decoration: BoxDecoration(gradient: AuthColors.primaryGradient),
            child: Column(
              children: [
                const SizedBox(height: 5),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 140,
                    height: 140,
                  ),
                ),
                const SizedBox(height: 5),
                // Mountain curve at bottom
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 30),
                  painter: MountainCurvePainter(),
                ),
              ],
            ),
          ),
          // Form content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: contentPadding,
                vertical: isSmallScreen ? 12.0 : 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Create\nAccount',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3142),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step 1 of 3: Enter your details',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),

                  // Name field
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_emailController.text == value) {
                          _checkEmailAvailability(value);
                        }
                      });
                    },
                    suffixIcon: _isCheckingEmail
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _emailAvailable != null
                        ? Icon(
                            _emailAvailable!
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _emailAvailable! ? Colors.green : Colors.red,
                            size: 20,
                          )
                        : null,
                  ),

                  // Email status message
                  if (_emailMessage != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _emailAvailable == true
                              ? Icons.check_circle
                              : Icons.error,
                          size: 16,
                          color: _emailAvailable == true
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _emailMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: _emailAvailable == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: isSmallScreen ? 24 : 32),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuthColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Send Verification Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Login link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: AuthColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ], // Closes children of Column
              ), // Closes Column
            ), // Closes SingleChildScrollView
          ), // Closes Expanded
        ], // Closes children of Scaffold body Column
      ), // Closes Scaffold body Column
    ); // Closes Scaffold
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Color(0xFF2D3142)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, size: 20, color: AuthColors.primary),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// Custom painter for top-right wave decoration
class TopRightWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width * 0.3, 0)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.2,
        size.width * 0.4,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.6,
        size.width,
        size.height * 0.7,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
