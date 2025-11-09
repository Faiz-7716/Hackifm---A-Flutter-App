import 'package:hackifm/database/database_helper.dart';
import 'package:hackifm/models/models.dart';

/// Example usage of the SQLite database
class DatabaseExamples {
  final DatabaseHelper _db = DatabaseHelper();

  /// Example 1: Register a new user
  Future<void> registerUser(String email, String password, String name) async {
    final user = User(
      email: email,
      password: password, // In production, hash the password!
      name: name,
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      int id = await _db.insertUser(user.toMap());
      print('User registered with ID: $id');
    } catch (e) {
      print('Error registering user: $e');
    }
  }

  /// Example 2: Login user
  Future<User?> loginUser(String email, String password) async {
    try {
      final userData = await _db.getUserByEmail(email);
      
      if (userData != null && userData['password'] == password) {
        return User.fromMap(userData);
      }
      return null;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  /// Example 3: Add a course
  Future<void> addCourse() async {
    final course = Course(
      title: 'Flutter Development Masterclass',
      instructor: 'Dr. Angela Yu',
      duration: '40 hours',
      level: 'Intermediate',
      rating: 4.8,
      students: '125K',
      completed: 0,
    );

    try {
      int id = await _db.insertCourse(course.toMap());
      print('Course added with ID: $id');
    } catch (e) {
      print('Error adding course: $e');
    }
  }

  /// Example 4: Get all courses
  Future<List<Course>> getAllCourses() async {
    try {
      final coursesData = await _db.getAllCourses();
      return coursesData.map((data) => Course.fromMap(data)).toList();
    } catch (e) {
      print('Error getting courses: $e');
      return [];
    }
  }

  /// Example 5: Mark course as completed
  Future<void> markCourseCompleted(int courseId) async {
    try {
      await _db.updateCourse(courseId, {'completed': 1});
      print('Course marked as completed');
    } catch (e) {
      print('Error updating course: $e');
    }
  }

  /// Example 6: Apply for internship
  Future<void> applyForInternship(int userId, int internshipId) async {
    try {
      // Mark internship as applied
      await _db.updateInternship(internshipId, {'applied': 1});
      
      // Create application record
      await _db.insertApplication({
        'user_id': userId,
        'type': 'internship',
        'item_id': internshipId,
        'status': 'pending',
        'applied_date': DateTime.now().toIso8601String(),
      });
      
      print('Applied for internship successfully');
    } catch (e) {
      print('Error applying for internship: $e');
    }
  }

  /// Example 7: Get user's applications
  Future<List<Map<String, dynamic>>> getUserApplications(int userId) async {
    try {
      return await _db.getUserApplications(userId);
    } catch (e) {
      print('Error getting applications: $e');
      return [];
    }
  }

  /// Example 8: Add internship
  Future<void> addInternship() async {
    final internship = Internship(
      title: 'Software Engineering Intern',
      company: 'Google',
      duration: '3 months',
      type: 'Remote',
      description: 'Join our team to work on cutting edge technologies',
    );

    try {
      int id = await _db.insertInternship(internship.toMap());
      print('Internship added with ID: $id');
    } catch (e) {
      print('Error adding internship: $e');
    }
  }

  /// Example 9: Register for hackathon
  Future<void> registerForHackathon(int userId, int hackathonId) async {
    try {
      // Mark hackathon as registered
      await _db.updateHackathon(hackathonId, {'registered': 1});
      
      // Create application record
      await _db.insertApplication({
        'user_id': userId,
        'type': 'hackathon',
        'item_id': hackathonId,
        'status': 'registered',
        'applied_date': DateTime.now().toIso8601String(),
      });
      
      print('Registered for hackathon successfully');
    } catch (e) {
      print('Error registering for hackathon: $e');
    }
  }

  /// Example 10: Initialize sample data
  Future<void> initializeSampleData() async {
    // Add sample courses
    await _db.insertCourse({
      'title': 'Flutter Development Masterclass',
      'instructor': 'Dr. Angela Yu',
      'duration': '40 hours',
      'level': 'Intermediate',
      'rating': 4.8,
      'students': '125K',
      'completed': 0,
    });

    await _db.insertCourse({
      'title': 'Machine Learning A-Z',
      'instructor': 'Kirill Eremenko',
      'duration': '44 hours',
      'level': 'Beginner',
      'rating': 4.7,
      'students': '890K',
      'completed': 0,
    });

    // Add sample internships
    await _db.insertInternship({
      'title': 'Software Engineering Intern',
      'company': 'Google',
      'duration': '3 months',
      'type': 'Remote',
      'description': 'Join our team to work on cutting edge technologies',
      'applied': 0,
    });

    await _db.insertInternship({
      'title': 'Product Design Intern',
      'company': 'Microsoft',
      'duration': '2 months',
      'type': 'Hybrid',
      'description': 'Design user-centered experiences for millions of users',
      'applied': 0,
    });

    // Add sample hackathons
    await _db.insertHackathon({
      'title': 'AI Innovation Challenge 2025',
      'organizer': 'Google',
      'date': 'Dec 15-17, 2025',
      'prize': '₹50,00,000',
      'participants': '500+',
      'status': 'Open',
      'registered': 0,
    });

    print('Sample data initialized!');
  }
}
