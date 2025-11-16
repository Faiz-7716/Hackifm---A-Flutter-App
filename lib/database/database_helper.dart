import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'hackifm.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create Courses table
    await db.execute('''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        instructor TEXT,
        duration TEXT,
        level TEXT,
        rating REAL,
        students TEXT,
        completed INTEGER DEFAULT 0
      )
    ''');

    // Create Internships table
    await db.execute('''
      CREATE TABLE internships(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        company TEXT,
        duration TEXT,
        type TEXT,
        description TEXT,
        applied INTEGER DEFAULT 0
      )
    ''');

    // Create Hackathons table
    await db.execute('''
      CREATE TABLE hackathons(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        organizer TEXT,
        date TEXT,
        prize TEXT,
        participants TEXT,
        status TEXT,
        registered INTEGER DEFAULT 0
      )
    ''');

    // Create Applications table
    await db.execute('''
      CREATE TABLE applications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        type TEXT NOT NULL,
        item_id INTEGER NOT NULL,
        status TEXT DEFAULT 'pending',
        applied_date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  // USER CRUD OPERATIONS
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    Database db = await database;
    return await db.update('users', user, where: 'id = ?', whereArgs: [id]);
  }

  // COURSE CRUD OPERATIONS
  Future<int> insertCourse(Map<String, dynamic> course) async {
    Database db = await database;
    return await db.insert('courses', course);
  }

  Future<List<Map<String, dynamic>>> getAllCourses() async {
    Database db = await database;
    return await db.query('courses');
  }

  Future<int> updateCourse(int id, Map<String, dynamic> course) async {
    Database db = await database;
    return await db.update('courses', course, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCourse(int id) async {
    Database db = await database;
    return await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  // INTERNSHIP CRUD OPERATIONS
  Future<int> insertInternship(Map<String, dynamic> internship) async {
    Database db = await database;
    return await db.insert('internships', internship);
  }

  Future<List<Map<String, dynamic>>> getAllInternships() async {
    Database db = await database;
    return await db.query('internships');
  }

  Future<int> updateInternship(int id, Map<String, dynamic> internship) async {
    Database db = await database;
    return await db.update(
      'internships',
      internship,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteInternship(int id) async {
    Database db = await database;
    return await db.delete('internships', where: 'id = ?', whereArgs: [id]);
  }

  // HACKATHON CRUD OPERATIONS
  Future<int> insertHackathon(Map<String, dynamic> hackathon) async {
    Database db = await database;
    return await db.insert('hackathons', hackathon);
  }

  Future<List<Map<String, dynamic>>> getAllHackathons() async {
    Database db = await database;
    return await db.query('hackathons');
  }

  Future<int> updateHackathon(int id, Map<String, dynamic> hackathon) async {
    Database db = await database;
    return await db.update(
      'hackathons',
      hackathon,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteHackathon(int id) async {
    Database db = await database;
    return await db.delete('hackathons', where: 'id = ?', whereArgs: [id]);
  }

  // APPLICATION CRUD OPERATIONS
  Future<int> insertApplication(Map<String, dynamic> application) async {
    Database db = await database;
    return await db.insert('applications', application);
  }

  Future<List<Map<String, dynamic>>> getUserApplications(int userId) async {
    Database db = await database;
    return await db.query(
      'applications',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateApplicationStatus(int id, String status) async {
    Database db = await database;
    return await db.update(
      'applications',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // UTILITY FUNCTIONS
  Future<void> clearAllData() async {
    Database db = await database;
    await db.delete('users');
    await db.delete('courses');
    await db.delete('internships');
    await db.delete('hackathons');
    await db.delete('applications');
  }

  Future<void> closeDatabase() async {
    Database db = await database;
    await db.close();
  }
}
