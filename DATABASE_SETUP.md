# SQLite Database Setup for HackIFM App

## ✅ Setup Complete!

I've successfully set up SQLite database for your Flutter app with the following structure:

## 📦 Packages Added
- `sqflite: ^2.3.0` - SQLite plugin for Flutter
- `path_provider: ^2.1.1` - For finding the correct paths
- `path: ^1.8.3` - For path manipulation

## 📁 Files Created

### 1. `lib/database/database_helper.dart`
Main database helper class with CRUD operations for:
- **Users** - User authentication and profiles
- **Courses** - Course management
- **Internships** - Internship listings
- **Hackathons** - Hackathon events
- **Applications** - Track user applications

### 2. `lib/models/models.dart`
Model classes for:
- User
- Course
- Internship
- Hackathon

### 3. `lib/database/database_examples.dart`
Example usage showing how to:
- Register and login users
- Add/retrieve courses
- Apply for internships
- Register for hackathons
- Initialize sample data

## 📊 Database Schema

### Users Table
```sql
- id (INTEGER PRIMARY KEY)
- email (TEXT UNIQUE)
- password (TEXT)
- name (TEXT)
- created_at (TEXT)
```

### Courses Table
```sql
- id (INTEGER PRIMARY KEY)
- title (TEXT)
- instructor (TEXT)
- duration (TEXT)
- level (TEXT)
- rating (REAL)
- students (TEXT)
- completed (INTEGER)
```

### Internships Table
```sql
- id (INTEGER PRIMARY KEY)
- title (TEXT)
- company (TEXT)
- duration (TEXT)
- type (TEXT)
- description (TEXT)
- applied (INTEGER)
```

### Hackathons Table
```sql
- id (INTEGER PRIMARY KEY)
- title (TEXT)
- organizer (TEXT)
- date (TEXT)
- prize (TEXT)
- participants (TEXT)
- status (TEXT)
- registered (INTEGER)
```

### Applications Table
```sql
- id (INTEGER PRIMARY KEY)
- user_id (INTEGER)
- type (TEXT)
- item_id (INTEGER)
- status (TEXT)
- applied_date (TEXT)
```

## 🚀 How to Use

### Initialize Database
```dart
import 'package:hackifm/database/database_helper.dart';

final db = DatabaseHelper();
```

### Register a User
```dart
await db.insertUser({
  'email': 'user@example.com',
  'password': 'password123', // Hash in production!
  'name': 'Alex Johnson',
  'created_at': DateTime.now().toIso8601String(),
});
```

### Login User
```dart
final user = await db.getUserByEmail('user@example.com');
if (user != null && user['password'] == 'password123') {
  print('Login successful!');
}
```

### Add a Course
```dart
await db.insertCourse({
  'title': 'Flutter Development',
  'instructor': 'Dr. Angela Yu',
  'duration': '40 hours',
  'level': 'Intermediate',
  'rating': 4.8,
  'students': '125K',
  'completed': 0,
});
```

### Get All Courses
```dart
List<Map<String, dynamic>> courses = await db.getAllCourses();
for (var course in courses) {
  print(course['title']);
}
```

### Apply for Internship
```dart
// Update internship as applied
await db.updateInternship(internshipId, {'applied': 1});

// Create application record
await db.insertApplication({
  'user_id': userId,
  'type': 'internship',
  'item_id': internshipId,
  'status': 'pending',
  'applied_date': DateTime.now().toIso8601String(),
});
```

### Get User Applications
```dart
List<Map<String, dynamic>> applications = await db.getUserApplications(userId);
print('Total applications: ${applications.length}');
```

## 💡 Integration with Your App

### In Login Screen
```dart
import 'package:hackifm/database/database_helper.dart';

final db = DatabaseHelper();

// On login button press
final user = await db.getUserByEmail(emailController.text);
if (user != null && user['password'] == passwordController.text) {
  // Navigate to home screen
  Navigator.pushReplacementNamed(context, '/home');
}
```

### In Signup Screen
```dart
// On signup button press
await db.insertUser({
  'email': emailController.text,
  'password': passwordController.text,
  'name': nameController.text,
  'created_at': DateTime.now().toIso8601String(),
});
```

### In Internships Page
```dart
// Load internships from database
final internships = await db.getAllInternships();
setState(() {
  // Update UI with database data
});
```

### In Apply Button
```dart
// When user clicks Apply
await db.updateInternship(internshipId, {'applied': 1});
await db.insertApplication({
  'user_id': currentUserId,
  'type': 'internship',
  'item_id': internshipId,
  'status': 'pending',
  'applied_date': DateTime.now().toIso8601String(),
});

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Application submitted!')),
);
```

## 🔒 Security Notes

**IMPORTANT:**
1. **Never store plain text passwords!** Use a package like `crypto` to hash passwords:
```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

String hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}
```

2. Consider using **encrypted_shared_preferences** for storing sensitive user session data.

## 📱 Next Steps

1. ✅ Packages installed
2. ✅ Database helper created
3. ✅ Models defined
4. ✅ Examples provided

### To integrate:
1. Use `DatabaseHelper()` in your login/signup screens
2. Replace hardcoded data in Internships/Courses/Hackathons pages with database queries
3. Implement user authentication flow
4. Add password hashing for security
5. Test on your device!

## 🧪 Testing the Database

Run this in your app's initialization:
```dart
import 'package:hackifm/database/database_examples.dart';

// Initialize sample data
final examples = DatabaseExamples();
await examples.initializeSampleData();
```

Your SQLite database is now ready to use! 🎉
