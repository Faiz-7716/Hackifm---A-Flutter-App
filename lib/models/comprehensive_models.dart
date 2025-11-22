import 'dart:convert';

// ==================== INTERNSHIP MODEL ====================
class Internship {
  final int? id;
  final String title;
  final String company;
  final String? companyLogo;
  final String? companyDescription;
  final String? description;

  // Job Details
  final String? workType; // Remote, Hybrid, Onsite
  final String? internshipType; // Full-time, Part-time, Project-based, Research
  final bool isPaid;
  final String? stipendType; // Fixed, Performance-based, Unpaid
  final int? stipendMin;
  final int? stipendMax;
  final String? duration;
  final String? location;
  final String? category;

  // Skills & Experience
  final String? skillsRequired; // JSON array
  final String? experienceLevel; // Beginner, Intermediate, Advanced
  final String? toolsTechnologies; // JSON array

  // Eligibility
  final String? eligibility; // JSON object

  // Job Description
  final String? responsibilities;
  final String? whatYouWillLearn;

  // Application Details
  final String? applicationDeadline;
  final String? applyLink;
  final bool applyThroughPlatform;

  // Analytics
  final int viewsCount;
  final int clicksCount;
  final int appliedCount;

  // Admin/Status
  final String status;
  final bool isActive;
  final int? submittedBy;
  final String createdAt;
  final String updatedAt;

  Internship({
    this.id,
    required this.title,
    required this.company,
    this.companyLogo,
    this.companyDescription,
    this.description,
    this.workType,
    this.internshipType,
    this.isPaid = false,
    this.stipendType,
    this.stipendMin,
    this.stipendMax,
    this.duration,
    this.location,
    this.category,
    this.skillsRequired,
    this.experienceLevel,
    this.toolsTechnologies,
    this.eligibility,
    this.responsibilities,
    this.whatYouWillLearn,
    this.applicationDeadline,
    this.applyLink,
    this.applyThroughPlatform = true,
    this.viewsCount = 0,
    this.clicksCount = 0,
    this.appliedCount = 0,
    this.status = 'pending',
    this.isActive = true,
    this.submittedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      id: json['id'],
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      companyLogo: json['company_logo'],
      companyDescription: json['company_description'],
      description: json['description'],
      workType: json['work_type'],
      internshipType: json['internship_type'],
      isPaid: json['is_paid'] ?? false,
      stipendType: json['stipend_type'],
      stipendMin: json['stipend_min'],
      stipendMax: json['stipend_max'],
      duration: json['duration'],
      location: json['location'],
      category: json['category'],
      skillsRequired: json['skills_required'],
      experienceLevel: json['experience_level'],
      toolsTechnologies: json['tools_technologies'],
      eligibility: json['eligibility'],
      responsibilities: json['responsibilities'],
      whatYouWillLearn: json['what_you_will_learn'],
      applicationDeadline: json['application_deadline'],
      applyLink: json['apply_link'],
      applyThroughPlatform: json['apply_through_platform'] ?? true,
      viewsCount: json['views_count'] ?? 0,
      clicksCount: json['clicks_count'] ?? 0,
      appliedCount: json['applied_count'] ?? 0,
      status: json['status'] ?? 'pending',
      isActive: json['is_active'] ?? true,
      submittedBy: json['submitted_by'],
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'company_logo': companyLogo,
      'company_description': companyDescription,
      'description': description,
      'work_type': workType,
      'internship_type': internshipType,
      'is_paid': isPaid,
      'stipend_type': stipendType,
      'stipend_min': stipendMin,
      'stipend_max': stipendMax,
      'duration': duration,
      'location': location,
      'category': category,
      'skills_required': skillsRequired,
      'experience_level': experienceLevel,
      'tools_technologies': toolsTechnologies,
      'eligibility': eligibility,
      'responsibilities': responsibilities,
      'what_you_will_learn': whatYouWillLearn,
      'application_deadline': applicationDeadline,
      'apply_link': applyLink,
      'apply_through_platform': applyThroughPlatform,
      'views_count': viewsCount,
      'clicks_count': clicksCount,
      'applied_count': appliedCount,
      'status': status,
      'is_active': isActive,
      'submitted_by': submittedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper methods
  List<String> getSkillsList() {
    if (skillsRequired == null) return [];
    try {
      return List<String>.from(jsonDecode(skillsRequired!));
    } catch (e) {
      return skillsRequired!.split(',').map((s) => s.trim()).toList();
    }
  }

  List<String> getToolsList() {
    if (toolsTechnologies == null) return [];
    try {
      return List<String>.from(jsonDecode(toolsTechnologies!));
    } catch (e) {
      return toolsTechnologies!.split(',').map((s) => s.trim()).toList();
    }
  }

  Map<String, dynamic> getEligibilityMap() {
    if (eligibility == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(eligibility!));
    } catch (e) {
      return {};
    }
  }
}

// ==================== COURSE MODEL ====================
class CourseModel {
  final int? id;
  final String title;
  final String? platform; // Udemy, Scaler, FreeCodeCamp
  final String? instructor;
  final String? description;
  final String? courseLink; // External course URL
  final String? thumbnail; // Course thumbnail URL
  final String? whatYouWillLearn; // JSON array of learning points
  final String? duration;
  final String? level;
  final bool isPaid;
  final double? price;
  final String? category;
  final int viewsCount;
  final int enrolledCount;
  final double rating;
  final String status;
  final int? submittedBy;
  final String createdAt;
  final String updatedAt;

  CourseModel({
    this.id,
    required this.title,
    this.platform,
    this.instructor,
    this.description,
    this.courseLink,
    this.thumbnail,
    this.whatYouWillLearn,
    this.duration,
    this.level,
    this.isPaid = false,
    this.price,
    this.category,
    this.viewsCount = 0,
    this.enrolledCount = 0,
    this.rating = 0.0,
    this.status = 'pending',
    this.submittedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'] ?? '',
      platform: json['platform'],
      instructor: json['instructor'],
      description: json['description'],
      courseLink: json['course_link'],
      thumbnail: json['thumbnail'],
      whatYouWillLearn: json['what_you_will_learn'],
      duration: json['duration'],
      level: json['level'],
      isPaid: json['is_paid'] ?? false,
      price: json['price']?.toDouble(),
      category: json['category'],
      viewsCount: json['views_count'] ?? 0,
      enrolledCount: json['enrolled_count'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      submittedBy: json['submitted_by'],
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'platform': platform,
      'instructor': instructor,
      'description': description,
      'course_link': courseLink,
      'thumbnail': thumbnail,
      'what_you_will_learn': whatYouWillLearn,
      'duration': duration,
      'level': level,
      'is_paid': isPaid,
      'price': price,
      'category': category,
      'views_count': viewsCount,
      'enrolled_count': enrolledCount,
      'rating': rating,
      'status': status,
      'submitted_by': submittedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ==================== EVENT MODEL ====================
class EventModel {
  final int? id;
  final String title;
  final String? organizer;
  final String? description;
  final String? eventType;
  final String? category;
  final String? startDate;
  final String? endDate;
  final String? location;
  final String? registrationDeadline;
  final int? maxParticipants;
  final int currentParticipants;
  final int viewsCount;
  final String? prizePool;
  final String status;
  final int? submittedBy;
  final String createdAt;
  final String updatedAt;

  EventModel({
    this.id,
    required this.title,
    this.organizer,
    this.description,
    this.eventType,
    this.category,
    this.startDate,
    this.endDate,
    this.location,
    this.registrationDeadline,
    this.maxParticipants,
    this.currentParticipants = 0,
    this.viewsCount = 0,
    this.prizePool,
    this.status = 'pending',
    this.submittedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'] ?? '',
      organizer: json['organizer'],
      description: json['description'],
      eventType: json['event_type'],
      category: json['category'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      location: json['location'],
      registrationDeadline: json['registration_deadline'],
      maxParticipants: json['max_participants'],
      currentParticipants: json['current_participants'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      prizePool: json['prize_pool'],
      status: json['status'] ?? 'pending',
      submittedBy: json['submitted_by'],
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'organizer': organizer,
      'description': description,
      'event_type': eventType,
      'category': category,
      'start_date': startDate,
      'end_date': endDate,
      'location': location,
      'registration_deadline': registrationDeadline,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'views_count': viewsCount,
      'prize_pool': prizePool,
      'status': status,
      'submitted_by': submittedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ==================== NOTIFICATION MODEL ====================
class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String? type;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }
}

// ==================== USER PREFERENCES MODEL ====================
class UserPreferences {
  final int id;
  final int userId;
  final bool darkMode;
  final bool notificationEnabled;
  final bool emailNotifications;
  final String? interests;
  final String? preferredLocations;
  final String updatedAt;

  UserPreferences({
    required this.id,
    required this.userId,
    this.darkMode = false,
    this.notificationEnabled = true,
    this.emailNotifications = true,
    this.interests,
    this.preferredLocations,
    required this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'],
      userId: json['user_id'],
      darkMode: json['dark_mode'] ?? false,
      notificationEnabled: json['notification_enabled'] ?? true,
      emailNotifications: json['email_notifications'] ?? true,
      interests: json['interests'],
      preferredLocations: json['preferred_locations'],
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'dark_mode': darkMode,
      'notification_enabled': notificationEnabled,
      'email_notifications': emailNotifications,
      'interests': interests,
      'preferred_locations': preferredLocations,
      'updated_at': updatedAt,
    };
  }
}
