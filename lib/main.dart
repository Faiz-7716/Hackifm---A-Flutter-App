import 'package:flutter/material.dart';
import 'package:hackifm/screens/forgot_password_screen.dart';
import 'package:hackifm/screens/home_screen.dart';
import 'package:hackifm/screens/login_screen.dart';
import 'package:hackifm/screens/opportunity_list_screen.dart';
import 'package:hackifm/screens/profile_screen.dart';
import 'package:hackifm/screens/signup_screen.dart';
import 'package:hackifm/screens/splash_screen.dart';
import 'package:hackifm/screens/submit_opportunity_screen.dart';

void main() => runApp(const HackIFMApp());

class HackIFMApp extends StatelessWidget {
  const HackIFMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hackifm',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05060A),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        // Setup Google Fonts here if you add the package
        // textTheme: GoogleFonts.poppinsTextTheme(
        //   Theme.of(context).textTheme,
        // ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      // The initial route is the splash screen
      home: const SplashScreen(),
      // Named routes for navigation
      routes: {
        '/home': (context) =>
            const HomeScreen(), // Root route after splash/auth (use '/home' because `home` is specified)
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/internships': (context) =>
            const OpportunityListScreen(categoryName: 'Internships'),
        '/hackathons': (context) =>
            const OpportunityListScreen(categoryName: 'Hackathons'),
        '/courses': (context) =>
            const OpportunityListScreen(categoryName: 'Courses'),
        '/events': (context) =>
            const OpportunityListScreen(categoryName: 'Events'),
        '/submit': (context) => const SubmitOpportunityScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
