import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hackifm/widgets/animated_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _showButtons = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Check if first time user
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (mounted) {
      if (!hasSeenOnboarding) {
        // First time user - show onboarding
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        // Returning user - show buttons
        setState(() => _showButtons = true);
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A), // Deep premium navy
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo and text in center
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo (uses asset if available)
                  AnimatedLogo(
                    size: isSmallScreen ? 160 : 220,
                    imageAssetPath: 'assets/logo.png',
                    primaryColor: const Color(0xFF3498DB),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Tagline
                  Text(
                    'Ideas - Future - Mastery',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // Loading animation or buttons at bottom
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 32.0 : 48.0,
                  vertical: 40.0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  child: _showButtons
                      ? FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            key: const ValueKey('buttons'),
                            children: [
                              // Sign Up Button
                              SizedBox(
                                width: double.infinity,
                                height: isSmallScreen ? 50 : 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/signup-new',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF2874A6),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: Text(
                                    'REGISTER',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 16),

                              // Sign In Button
                              SizedBox(
                                width: double.infinity,
                                height: isSmallScreen ? 50 : 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/login',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF2874A6),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _buildLoadingAnimation(isSmallScreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation(bool isSmallScreen) {
    return Column(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated circles loading indicator
        SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      -20 * (value > 0.5 ? 1 - value : value) * 2,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: isSmallScreen ? 12 : 14,
                      height: isSmallScreen ? 12 : 14,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onEnd: () {
                  if (mounted && !_showButtons) {
                    // Restart animation
                    Future.delayed(Duration(milliseconds: 200 * index), () {
                      if (mounted) setState(() {});
                    });
                  }
                },
              );
            }),
          ),
        ),
        const SizedBox(height: 20),

        // Loading text with fade animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.3, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            );
          },
          onEnd: () {
            if (mounted && !_showButtons) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) setState(() {});
              });
            }
          },
        ),
      ],
    );
  }
}
