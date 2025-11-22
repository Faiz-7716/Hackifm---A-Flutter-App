import 'package:flutter/material.dart';
import 'package:hackifm/screens/student/courses_screen.dart';
import 'package:hackifm/screens/events_screen.dart';
import 'package:hackifm/screens/student/home_page_content.dart';
import 'package:hackifm/screens/student/internships_page_content.dart';
import 'package:hackifm/screens/student/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePageContent(
        onNavigateToTab: _onItemTapped,
      ), // Pass callback to switch tabs
      const InternshipsPageContent(),
      const CoursesScreen(),
      const EventsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;

    return Scaffold(
      body: Row(
        children: [
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
              backgroundColor: Colors.white,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: const Color(0xFF3498DB),
              unselectedItemColor: Colors.grey[600],
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 11,
              unselectedFontSize: 11,
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
