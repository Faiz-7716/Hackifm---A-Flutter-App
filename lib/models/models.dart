class User {
  final int? id;
  final String email;
  final String password;
  final String? name;
  final String createdAt;

  User({
    this.id,
    required this.email,
    required this.password,
    this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      createdAt: map['created_at'],
    );
  }
}

class Course {
  final int? id;
  final String title;
  final String? instructor;
  final String? duration;
  final String? level;
  final double? rating;
  final String? students;
  final int completed;

  Course({
    this.id,
    required this.title,
    this.instructor,
    this.duration,
    this.level,
    this.rating,
    this.students,
    this.completed = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'duration': duration,
      'level': level,
      'rating': rating,
      'students': students,
      'completed': completed,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      title: map['title'],
      instructor: map['instructor'],
      duration: map['duration'],
      level: map['level'],
      rating: map['rating'],
      students: map['students'],
      completed: map['completed'] ?? 0,
    );
  }
}

class Internship {
  final int? id;
  final String title;
  final String? company;
  final String? duration;
  final String? type;
  final String? description;
  final int applied;

  Internship({
    this.id,
    required this.title,
    this.company,
    this.duration,
    this.type,
    this.description,
    this.applied = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'duration': duration,
      'type': type,
      'description': description,
      'applied': applied,
    };
  }

  factory Internship.fromMap(Map<String, dynamic> map) {
    return Internship(
      id: map['id'],
      title: map['title'],
      company: map['company'],
      duration: map['duration'],
      type: map['type'],
      description: map['description'],
      applied: map['applied'] ?? 0,
    );
  }
}

class Hackathon {
  final int? id;
  final String title;
  final String? organizer;
  final String? date;
  final String? prize;
  final String? participants;
  final String? status;
  final int registered;

  Hackathon({
    this.id,
    required this.title,
    this.organizer,
    this.date,
    this.prize,
    this.participants,
    this.status,
    this.registered = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'organizer': organizer,
      'date': date,
      'prize': prize,
      'participants': participants,
      'status': status,
      'registered': registered,
    };
  }

  factory Hackathon.fromMap(Map<String, dynamic> map) {
    return Hackathon(
      id: map['id'],
      title: map['title'],
      organizer: map['organizer'],
      date: map['date'],
      prize: map['prize'],
      participants: map['participants'],
      status: map['status'],
      registered: map['registered'] ?? 0,
    );
  }
}
