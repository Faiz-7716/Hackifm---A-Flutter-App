import 'package:flutter/material.dart';
import 'package:hackifm/services/api_service.dart';

class HomePageContent extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomePageContent({super.key, this.onNavigateToTab});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String userName = 'User';
  int coursesCompleted = 0;
  int activeApplications = 0;
  int eventsParticipated = 0;
  bool isLoadingProgress = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final apiService = ApiService();

      // Load user name
      final userResponse = await apiService.getCurrentUser();
      print('Home - getCurrentUser response: $userResponse');
      if (userResponse['success'] == true && userResponse['user'] != null) {
        final fullName = userResponse['user']['name'];
        print('Home - Full name from API: $fullName');
        setState(() {
          userName = fullName?.split(' ')[0] ?? 'User';
        });
        print('Home - Set userName to: $userName');
      } else {
        print(
          'Home - API call failed or no user data: ${userResponse['message']}',
        );
      }

      // Load progress stats
      final progressResponse = await apiService.getUserProgress();
      print('Home - getUserProgress response: $progressResponse');
      if (progressResponse['success'] == true) {
        setState(() {
          coursesCompleted = progressResponse['coursesCompleted'] ?? 0;
          activeApplications = progressResponse['activeApplications'] ?? 0;
          eventsParticipated = progressResponse['eventsParticipated'] ?? 0;
          isLoadingProgress = false;
        });
        print(
          'Home - Progress loaded: Courses=$coursesCompleted, Apps=$activeApplications, Events=$eventsParticipated',
        );
      } else {
        print('Home - Failed to load progress: ${progressResponse['message']}');
        setState(() {
          isLoadingProgress = false;
        });
      }
    } catch (e) {
      print('Home - Error loading user data: $e');
      setState(() {
        isLoadingProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final horizontalPadding = isDesktop ? 40.0 : (isTablet ? 32.0 : 20.0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1400 : double.infinity,
                  minHeight: screenHeight - 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with user greeting
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Hello, $userName!',
                                  style: TextStyle(
                                    fontSize: isDesktop
                                        ? 32
                                        : (isTablet ? 30 : 28),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ready to learn today?',
                                style: TextStyle(
                                  fontSize: isDesktop ? 18 : 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            // Navigate to Profile tab (index 4)
                            widget.onNavigateToTab?.call(4);
                          },
                          child: CircleAvatar(
                            radius: isDesktop ? 32 : (isTablet ? 30 : 28),
                            backgroundColor: const Color(0xFF6366F1),
                            child: Text(
                              userName[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isDesktop ? 28 : (isTablet ? 26 : 24),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isDesktop ? 32 : 24),

                    // Search bar
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 24 : 20,
                        vertical: isDesktop ? 18 : 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.grey[400],
                            size: isDesktop ? 26 : 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search courses, internships',
                              style: TextStyle(
                                fontSize: isDesktop ? 18 : 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isDesktop ? 32 : 24),

                    // Progress card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        isDesktop ? 32 : (isTablet ? 28 : 24),
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Progress',
                            style: TextStyle(
                              fontSize: isDesktop ? 26 : (isTablet ? 24 : 22),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: isDesktop ? 28 : 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: isLoadingProgress
                                          ? SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              '$coursesCompleted',
                                              style: TextStyle(
                                                fontSize: isDesktop
                                                    ? 48
                                                    : (isTablet ? 40 : 32),
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Courses\nCompleted',
                                        style: TextStyle(
                                          fontSize: isDesktop
                                              ? 14
                                              : (isTablet ? 13 : 11),
                                          color: Colors.white.withOpacity(0.9),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: isDesktop ? 16 : (isTablet ? 12 : 8),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: isLoadingProgress
                                          ? SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              '$activeApplications',
                                              style: TextStyle(
                                                fontSize: isDesktop
                                                    ? 48
                                                    : (isTablet ? 40 : 32),
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Active\nApplications',
                                        style: TextStyle(
                                          fontSize: isDesktop
                                              ? 14
                                              : (isTablet ? 13 : 11),
                                          color: Colors.white.withOpacity(0.9),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: isDesktop ? 16 : (isTablet ? 12 : 8),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: isLoadingProgress
                                          ? SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              '$eventsParticipated',
                                              style: TextStyle(
                                                fontSize: isDesktop
                                                    ? 48
                                                    : (isTablet ? 40 : 32),
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Events\nParticipated',
                                        style: TextStyle(
                                          fontSize: isDesktop
                                              ? 14
                                              : (isTablet ? 13 : 11),
                                          color: Colors.white.withOpacity(0.9),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isDesktop ? 40 : 28),

                    // Quick Access section
                    Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: isDesktop ? 26 : (isTablet ? 24 : 22),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 24 : 16),

                    // Quick access grid - Responsive
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2; // Mobile default
                        double childAspectRatio = 1.1;

                        if (isDesktop) {
                          crossAxisCount = 4; // Desktop: 4 columns
                          childAspectRatio = 0.95;
                        } else if (isTablet) {
                          crossAxisCount = 3; // Tablet: 3 columns
                          childAspectRatio = 1.0;
                        }

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: isDesktop ? 20 : 16,
                          crossAxisSpacing: isDesktop ? 20 : 16,
                          childAspectRatio: childAspectRatio,
                          children: [
                            _buildQuickAccessCard(
                              'Internships',
                              'Browse\nroles',
                              Icons.work_outline,
                              const Color(0xFF6366F1),
                              () => widget.onNavigateToTab?.call(
                                1,
                              ), // Navigate to Internships tab (index 1)
                              isDesktop,
                              isTablet,
                            ),
                            _buildQuickAccessCard(
                              'Courses',
                              'Learn\nskills',
                              Icons.school_outlined,
                              const Color(0xFF10B981),
                              () => widget.onNavigateToTab?.call(
                                2,
                              ), // Navigate to Courses tab (index 2)
                              isDesktop,
                              isTablet,
                            ),
                            _buildQuickAccessCard(
                              'Events',
                              'Join now',
                              Icons.emoji_events_outlined,
                              const Color(0xFF6366F1),
                              () => widget.onNavigateToTab?.call(
                                3,
                              ), // Navigate to Events tab (index 3)
                              isDesktop,
                              isTablet,
                            ),
                            _buildQuickAccessCard(
                              'Profile',
                              'Your\ninfo',
                              Icons.person_outline,
                              const Color(0xFF10B981),
                              () => widget.onNavigateToTab?.call(
                                4,
                              ), // Navigate to Profile tab (index 4)
                              isDesktop,
                              isTablet,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDesktop,
    bool isTablet,
  ) {
    final cardPadding = isDesktop ? 24.0 : (isTablet ? 22.0 : 20.0);
    final iconSize = isDesktop ? 64.0 : (isTablet ? 60.0 : 56.0);
    final iconInnerSize = isDesktop ? 32.0 : (isTablet ? 30.0 : 28.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: iconInnerSize),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
