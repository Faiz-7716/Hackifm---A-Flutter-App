import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hackifm/providers/auth_provider.dart';
import 'package:hackifm/screens/forgot_password_screen.dart';
import 'package:hackifm/screens/home_screen.dart';
import 'package:hackifm/screens/login_screen.dart';
import 'package:hackifm/screens/opportunity_list_screen.dart';
import 'package:hackifm/screens/profile_screen.dart';
import 'package:hackifm/screens/signup_screen.dart';
import 'package:hackifm/screens/auth/name_email_screen.dart';
import 'package:hackifm/screens/splash_screen.dart';
import 'package:hackifm/screens/account_type_selection_screen.dart';
import 'package:hackifm/screens/login_activity_screen.dart';
import 'package:hackifm/screens/onboarding/onboarding_screen.dart';
import 'package:hackifm/screens/events_screen.dart';
import 'package:hackifm/screens/courses_screen.dart';
import 'package:hackifm/screens/submit_opportunity_screen.dart';
import 'package:hackifm/database/database_viewer.dart';
import 'package:hackifm/screens/admin_login_screen.dart';
import 'package:hackifm/screens/admin_home_screen.dart';
import 'package:hackifm/screens/admin_add_internship_screen.dart';
import 'package:hackifm/screens/admin_add_course_screen.dart';
import 'package:hackifm/screens/admin_add_hackathon_screen.dart';
import 'package:hackifm/screens/admin_manage_internships_screen.dart';
import 'package:hackifm/screens/admin_manage_courses_screen.dart';
import 'package:hackifm/screens/admin_manage_hackathons_screen.dart';
import 'package:hackifm/screens/profile/edit_profile_screen.dart';
import 'package:hackifm/screens/profile/resume_screen.dart';
import 'package:hackifm/screens/profile/my_applications_screen.dart';
import 'package:hackifm/screens/profile/saved_items_screen.dart';
import 'package:hackifm/screens/profile/security_settings_screen.dart';
import 'package:hackifm/screens/profile/active_sessions_screen.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => AuthProvider(),
    child: const HackIFMApp(),
  ),
);

class HackIFMApp extends StatelessWidget {
  const HackIFMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hackifm',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF60A5FA),
          surface: Color(0xFFF8FAFC),
          error: Color(0xFFEF4444),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF60A5FA),
          surface: Color(0xFF1E293B),
          error: Color(0xFFEF4444),
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      // Named routes for navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) =>
            const HomeScreen(), // Root route after splash/auth (use '/home' because `home` is specified)
        '/login': (context) => const LoginPage(),
        '/signup': (context) =>
            const SignUpPage(), // Old signup - keep for backward compatibility
        '/signup-new': (context) =>
            const NameEmailScreen(), // New signup flow - step 1
        '/account-type-selection': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return AccountTypeSelectionScreen(
            userName: args['userName'],
            userEmail: args['userEmail'],
          );
        },
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/internships': (context) =>
            const OpportunityListScreen(categoryName: 'Internships'),
        '/hackathons': (context) => const EventsScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/events': (context) => const EventsScreen(),
        '/submit': (context) => const SubmitOpportunityScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/login-activity': (context) => const LoginActivityScreen(),
        '/database-viewer': (context) => const DatabaseViewerScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-home': (context) => const AdminHomeScreen(),
        '/admin-add-internship': (context) => const AdminAddInternshipScreen(),
        '/admin-add-course': (context) => const AdminAddCourseScreen(),
        '/admin-add-hackathon': (context) => const AdminAddHackathonScreen(),
        '/admin-manage-internships': (context) =>
            const AdminManageInternshipsScreen(),
        '/admin-manage-courses': (context) => const AdminManageCoursesScreen(),
        '/admin-manage-hackathons': (context) =>
            const AdminManageHackathonsScreen(),
        '/profile/edit': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return EditProfileScreen(user: args);
        },
        '/profile/resume': (context) => const ResumeScreen(),
        '/profile/applications': (context) => const MyApplicationsScreen(),
        '/profile/saved-items': (context) => const SavedItemsScreen(),
        '/profile/security': (context) => const SecuritySettingsScreen(),
        '/profile/sessions': (context) => const ActiveSessionsScreen(),
      },
    );
  }
}
