import 'package:flutter/material.dart';
import 'package:hackifm/services/api_service.dart';
import 'package:hackifm/screens/courses_screen.dart';
import 'package:hackifm/screens/events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const InternshipsPage(),
    const CoursesScreen(),
    const EventsScreen(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1024;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          // Side navigation for large screens
          if (isLargeScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(
                color: Color(0xFF3498DB),
                size: 32,
              ),
              unselectedIconTheme: IconThemeData(
                color: Colors.grey[600],
                size: 28,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: Color(0xFF3498DB),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.work_outline),
                  selectedIcon: Icon(Icons.work),
                  label: Text('Internships'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school),
                  label: Text('Courses'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  selectedIcon: Icon(Icons.emoji_events),
                  label: Text('Events'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
          // Main content
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      // Bottom navigation for mobile and tablet
      bottomNavigationBar: isLargeScreen
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: const Color(0xFF3498DB),
              unselectedItemColor: Colors.grey[600],
              selectedFontSize: isMediumScreen ? 14 : 12,
              unselectedFontSize: isMediumScreen ? 12 : 10,
              iconSize: isMediumScreen ? 28 : 24,
              backgroundColor: Colors.white,
              elevation: 8,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.work_outline),
                  activeIcon: Icon(Icons.work),
                  label: 'Internships',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.school_outlined),
                  activeIcon: Icon(Icons.school),
                  label: 'Courses',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_outlined),
                  activeIcon: Icon(Icons.emoji_events),
                  label: 'Events',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}

// Home Page Content
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth <= 1024;

    final horizontalPadding = isSmallScreen
        ? 16.0
        : (isMediumScreen ? 32.0 : 48.0);
    final verticalPadding = isSmallScreen
        ? 16.0
        : (isMediumScreen ? 24.0 : 32.0);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          top: verticalPadding + 16,
          bottom: verticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, Alex!',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? 24
                            : (isMediumScreen ? 28 : 32),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to learn today?',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? 14
                            : (isMediumScreen ? 16 : 18),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to profile page
                    final homeScreenState = context
                        .findAncestorStateOfType<_HomeScreenState>();
                    if (homeScreenState != null) {
                      homeScreenState._onItemTapped(4); // Profile is at index 4
                    }
                  },
                  child: CircleAvatar(
                    radius: isSmallScreen ? 24 : (isMediumScreen ? 28 : 32),
                    backgroundColor: const Color(0xFF5DADE2),
                    child: Icon(
                      Icons.person,
                      size: isSmallScreen ? 28 : (isMediumScreen ? 32 : 36),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: verticalPadding),

            // Search Bar
            GestureDetector(
              onTap: () {
                // Show search functionality
                showSearch(context: context, delegate: CustomSearchDelegate());
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 20,
                  vertical: isSmallScreen ? 14 : 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: const Color(0xFF3498DB),
                      size: isSmallScreen ? 22 : 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search courses, internships',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 15 : 16,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.tune,
                      color: Colors.grey[400],
                      size: isSmallScreen ? 20 : 22,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: verticalPadding),

            // Progress Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(
                isSmallScreen ? 20 : (isMediumScreen ? 24 : 28),
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B7FED), Color(0xFF8B9AFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B7FED).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Progress',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : (isMediumScreen ? 24 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '12',
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? 36
                                    : (isMediumScreen ? 42 : 48),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Courses\nCompleted',
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? 14
                                    : (isMediumScreen ? 16 : 18),
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '3',
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? 36
                                    : (isMediumScreen ? 42 : 48),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Active\nApplications',
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? 14
                                    : (isMediumScreen ? 16 : 18),
                                color: Colors.white.withOpacity(0.9),
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
            SizedBox(height: verticalPadding),

            // Quick Access Section
            Text(
              'Quick Access',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : (isMediumScreen ? 24 : 28),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Quick Access Grid
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = isSmallScreen
                    ? 2
                    : (isMediumScreen ? 3 : 4);
                double childAspectRatio = isSmallScreen ? 1.0 : 1.1;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isSmallScreen ? 12 : 16,
                  mainAxisSpacing: isSmallScreen ? 12 : 16,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildQuickAccessCard(
                      context,
                      'Internships',
                      'Find opportunities',
                      Icons.work,
                      const Color(0xFF7B8CFF),
                      isSmallScreen,
                    ),
                    _buildQuickAccessCard(
                      context,
                      'Courses',
                      'Learn new skills',
                      Icons.school,
                      const Color(0xFF5FD068),
                      isSmallScreen,
                    ),
                    _buildQuickAccessCard(
                      context,
                      'Events',
                      'Find opportunities',
                      Icons.emoji_events,
                      const Color(0xFF7B8CFF),
                      isSmallScreen,
                    ),
                    _buildQuickAccessCard(
                      context,
                      'Profile',
                      'Your activities',
                      Icons.person,
                      const Color(0xFF5FD068),
                      isSmallScreen,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to respective page based on title
        int pageIndex = 0;
        if (title == 'Internships') {
          pageIndex = 1;
        } else if (title == 'Courses') {
          pageIndex = 2;
        } else if (title == 'Events') {
          pageIndex = 3;
        } else if (title == 'Profile') {
          pageIndex = 4;
        }

        // Navigate by updating the parent HomeScreen state
        final homeScreenState = context
            .findAncestorStateOfType<_HomeScreenState>();
        if (homeScreenState != null) {
          homeScreenState._onItemTapped(pageIndex);
        }
      },
      child: Container(
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
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: isSmallScreen ? 24 : 28, color: color),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 13,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Search Delegate
class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('Search results for: $query'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = [
      'Flutter Development',
      'Machine Learning',
      'Web Development',
      'Software Engineering Intern',
      'Product Design',
      'AI Hackathon',
    ];

    final filteredSuggestions = suggestions
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.search, color: Color(0xFF3498DB)),
          title: Text(filteredSuggestions[index]),
          onTap: () {
            query = filteredSuggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}

// Internships Page
class InternshipsPage extends StatefulWidget {
  const InternshipsPage({super.key});

  @override
  State<InternshipsPage> createState() => _InternshipsPageState();
}

class _InternshipsPageState extends State<InternshipsPage> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> internships = [
    {
      'title': 'Software Engineering Intern',
      'company': 'Google',
      'duration': '3 months',
      'type': 'Remote',
      'description':
          'Join our team to work on cutting edge technologies and gain hands-on experience in software development.',
      'color': const Color(0xFF6B7FED),
    },
    {
      'title': 'Product Design Intern',
      'company': 'Microsoft',
      'duration': '2 months',
      'type': 'Hybrid',
      'description':
          'Design user-centered experiences for millions of users worldwide. Work with cross-functional teams.',
      'color': const Color(0xFF5FD068),
    },
    {
      'title': 'Data Science Intern',
      'company': 'Amazon',
      'duration': '4 months',
      'type': 'Remote',
      'description':
          'Work with big data and machine learning algorithms to solve real-world business problems.',
      'color': const Color(0xFF6B7FED),
    },
    {
      'title': 'Mobile App Developer',
      'company': 'Apple',
      'duration': '6 months',
      'type': 'Tech',
      'description':
          'Build innovative iOS applications and contribute to next-generation mobile experiences.',
      'color': const Color(0xFF5FD068),
    },
    {
      'title': 'Marketing Intern',
      'company': 'Meta',
      'duration': '3 months',
      'type': 'Full-Time',
      'description':
          'Create compelling marketing campaigns and analyze user engagement metrics.',
      'color': const Color(0xFF6B7FED),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth <= 1024;

    final horizontalPadding = isSmallScreen
        ? 16.0
        : (isMediumScreen ? 32.0 : 48.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {},
        ),
        title: Text(
          'Internships',
          style: TextStyle(
            color: Colors.black87,
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Filter Chips
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 12),
                    _buildFilterChip('Remote'),
                    const SizedBox(width: 12),
                    _buildFilterChip('Tech'),
                    const SizedBox(width: 12),
                    _buildFilterChip('Full-Time'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Internship Cards
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: internships.length,
                itemBuilder: (context, index) {
                  return _buildInternshipCard(
                    internships[index],
                    isSmallScreen,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B7FED) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInternshipCard(
    Map<String, dynamic> internship,
    bool isSmallScreen,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  internship['title'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                internship['duration'],
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            internship['company'],
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            internship['description'],
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 15,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF5FD068).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  internship['type'],
                  style: const TextStyle(
                    color: Color(0xFF3EA04A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B7FED),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 24 : 32,
                    vertical: isSmallScreen ? 12 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Courses Page
class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  final List<Map<String, dynamic>> courses = const [
    {
      'title': 'Flutter Development Masterclass',
      'instructor': 'Dr. Angela Yu',
      'duration': '40 hours',
      'level': 'Intermediate',
      'rating': 4.8,
      'students': '125K',
      'color': Color(0xFF6B7FED),
    },
    {
      'title': 'Machine Learning A-Z',
      'instructor': 'Kirill Eremenko',
      'duration': '44 hours',
      'level': 'Beginner',
      'rating': 4.7,
      'students': '890K',
      'color': Color(0xFF5FD068),
    },
    {
      'title': 'Web Development Bootcamp',
      'instructor': 'Colt Steele',
      'duration': '63 hours',
      'level': 'Beginner',
      'rating': 4.9,
      'students': '670K',
      'color': Color(0xFFFF6B9D),
    },
    {
      'title': 'AWS Certified Solutions Architect',
      'instructor': 'Stephane Maarek',
      'duration': '28 hours',
      'level': 'Advanced',
      'rating': 4.7,
      'students': '450K',
      'color': Color(0xFFFFB74D),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth <= 1024;

    final horizontalPadding = isSmallScreen
        ? 16.0
        : (isMediumScreen ? 32.0 : 48.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {},
        ),
        title: Text(
          'Courses',
          style: TextStyle(
            color: Colors.black87,
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Continue Learning',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return _buildCourseCard(courses[index], isSmallScreen);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Image Header
          Container(
            height: isSmallScreen ? 150 : 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  course['color'] as Color,
                  (course['color'] as Color).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_filled,
                size: isSmallScreen ? 60 : 80,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course['instructor'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star, size: 18, color: Colors.amber[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${course['rating']}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.people, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${course['students']}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B7FED).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            course['level'],
                            style: const TextStyle(
                              color: Color(0xFF6B7FED),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          course['duration'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.bookmark_border, color: Colors.grey[600]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Hackathon Page
class HackathonPage extends StatelessWidget {
  const HackathonPage({super.key});

  final List<Map<String, dynamic>> hackathons = const [
    {
      'title': 'AI Innovation Challenge 2025',
      'organizer': 'Google',
      'date': 'Dec 15-17, 2025',
      'prize': '₹40,00,000',
      'participants': '500+',
      'status': 'Open',
      'color': Color(0xFF6B7FED),
    },
    {
      'title': 'Blockchain Hackathon',
      'organizer': 'Ethereum Foundation',
      'date': 'Jan 10-12, 2026',
      'prize': '₹25,00,000',
      'participants': '300+',
      'status': 'Open',
      'color': Color(0xFF5FD068),
    },
    {
      'title': 'Green Tech Challenge',
      'organizer': 'Microsoft',
      'date': 'Nov 20-22, 2025',
      'prize': '₹20,00,000',
      'participants': '450+',
      'status': 'Closing Soon',
      'color': Color(0xFFFFB74D),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth <= 1024;

    final horizontalPadding = isSmallScreen
        ? 16.0
        : (isMediumScreen ? 32.0 : 48.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {},
        ),
        title: Text(
          'Hackathons',
          style: TextStyle(
            color: Colors.black87,
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Upcoming Hackathons',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: hackathons.length,
                itemBuilder: (context, index) {
                  return _buildHackathonCard(hackathons[index], isSmallScreen);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHackathonCard(
    Map<String, dynamic> hackathon,
    bool isSmallScreen,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            hackathon['color'] as Color,
            (hackathon['color'] as Color).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (hackathon['color'] as Color).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  hackathon['status'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.emoji_events,
                color: Colors.white.withOpacity(0.9),
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hackathon['title'],
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'by ${hackathon['organizer']}',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 8),
              Text(
                hackathon['date'],
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 15,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 8),
              Text(
                '${hackathon['participants']} participants',
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 15,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prize: ${hackathon['prize']}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: hackathon['color'] as Color,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 24 : 32,
                    vertical: isSmallScreen ? 12 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Register',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Profile Page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth <= 1024;

    final horizontalPadding = isSmallScreen
        ? 16.0
        : (isMediumScreen ? 32.0 : 48.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {},
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Profile Avatar
              CircleAvatar(
                radius: isSmallScreen ? 50 : 60,
                backgroundColor: const Color(0xFF5DADE2),
                child: Icon(
                  Icons.person,
                  size: isSmallScreen ? 50 : 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Alex Johnson',
                style: TextStyle(
                  fontSize: isSmallScreen ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'alex.johnson@email.com',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('12', 'Courses', isSmallScreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('3', 'Applications', isSmallScreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('5', 'Certificates', isSmallScreen),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Menu Items
              FutureBuilder<Map<String, dynamic>>(
                future: ApiService().getCurrentUser(),
                builder: (context, snapshot) {
                  final userData = snapshot.data?['user'] ?? {};
                  return GestureDetector(
                    onTap: () async {
                      if (userData.isNotEmpty) {
                        await Navigator.pushNamed(
                          context,
                          '/profile/edit',
                          arguments: userData,
                        );
                      }
                    },
                    child: _buildMenuItem(
                      Icons.person_outline,
                      'Edit Profile',
                      isSmallScreen,
                    ),
                  );
                },
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile/resume');
                },
                child: _buildMenuItem(
                  Icons.description_outlined,
                  'My Resume',
                  isSmallScreen,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile/applications');
                },
                child: _buildMenuItem(
                  Icons.work_outline,
                  'My Applications',
                  isSmallScreen,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile/saved-items');
                },
                child: _buildMenuItem(
                  Icons.bookmark_outline,
                  'Saved Items',
                  isSmallScreen,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile/security');
                },
                child: _buildMenuItem(
                  Icons.security,
                  'Security Settings',
                  isSmallScreen,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile/sessions');
                },
                child: _buildMenuItem(
                  Icons.devices,
                  'Active Sessions',
                  isSmallScreen,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/login-activity');
                },
                child: _buildMenuItem(
                  Icons.history,
                  'Login History',
                  isSmallScreen,
                ),
              ),
              _buildMenuItem(
                Icons.help_outline,
                'Help & Support',
                isSmallScreen,
              ),
              _buildMenuItem(
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                isSmallScreen,
              ),
              FutureBuilder<bool>(
                future: ApiService().isAdmin(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/database-viewer');
                          },
                          child: _buildMenuItem(
                            Icons.storage,
                            'Database Viewer',
                            isSmallScreen,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/admin-home');
                          },
                          child: _buildMenuItem(
                            Icons.admin_panel_settings,
                            'Admin Access',
                            isSmallScreen,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),
              // Logout Button
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Navigate to login screen
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 32 : 48,
                    vertical: isSmallScreen ? 14 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3498DB),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF3498DB),
          size: isSmallScreen ? 24 : 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 15 : 17,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () {},
      ),
    );
  }
}
