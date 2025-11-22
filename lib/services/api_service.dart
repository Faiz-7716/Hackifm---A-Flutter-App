import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Change this to your backend URL
  // For local testing on Chrome/web: Use your computer's IP address
  // For Android emulator: Use http://10.0.2.2:5000
  // For physical Android device: Use http://YOUR_COMPUTER_IP:5000
  static const String baseUrl = 'http://192.168.29.2:5000';

  final storage = const FlutterSecureStorage();

  // Session token - stored in memory for current session
  String? _sessionToken;

  // Helper method to get token from session or persistent storage
  Future<String?> _getToken() async {
    // Try session token first (for non-rememberMe logins)
    if (_sessionToken != null) {
      return _sessionToken;
    }
    // Fall back to persistent storage (for rememberMe logins)
    return await storage.read(key: 'jwt_token');
  }

  // ==================== AUTHENTICATION ====================

  /// User Signup
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check if the backend server is running.',
              );
            },
          );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// User Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check if the backend server is running.',
              );
            },
          );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print(
          'Login - Success! Token received: ${data['token']?.substring(0, 20)}...',
        );
        print('Login - User data: ${data['user']}');
        print('Login - RememberMe is: $rememberMe');

        // Always store token in session memory for current app session
        _sessionToken = data['token'];
        print('Login - Token stored in session memory');

        if (rememberMe) {
          print('Login - RememberMe is TRUE, saving to persistent storage...');
          // Store JWT token and user data in persistent storage
          await storage.write(key: 'jwt_token', value: data['token']);
          print('Login - Token saved to storage');

          // Store user data
          await storage.write(
            key: 'user_id',
            value: data['user']['id'].toString(),
          );
          await storage.write(key: 'user_name', value: data['user']['name']);
          await storage.write(key: 'user_email', value: data['user']['email']);
          await storage.write(key: 'user_role', value: data['user']['role']);
          print('Login - User data saved: ${data['user']['name']}');

          // Mark that user chose to be remembered
          await storage.write(key: 'remember_me', value: 'true');

          // Verify token was saved
          final savedToken = await storage.read(key: 'jwt_token');
          print(
            'Login - Verification: Token exists after save: ${savedToken != null}',
          );
        } else {
          print('Login - RememberMe is FALSE, using session-only storage');
          // Clear any existing stored credentials from previous sessions
          await storage.delete(key: 'jwt_token');
          await storage.delete(key: 'user_id');
          await storage.delete(key: 'user_name');
          await storage.delete(key: 'user_email');
          await storage.delete(key: 'user_role');
          await storage.delete(key: 'remember_me');
          print('Login - Token will be available for this session only');
        }

        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get Current User
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      // Check session token first, then persistent storage
      String? token = _sessionToken;
      if (token == null) {
        token = await storage.read(key: 'jwt_token');
      }

      print(
        'API - JWT Token: ${token != null ? "EXISTS (${token.substring(0, 20)}...)" : "NULL"}',
      );
      print(
        'API - Token source: ${_sessionToken != null ? "Session" : "Storage"}',
      );

      if (token == null) {
        print('API - No token found, returning not authenticated');
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('API - Calling /api/auth/me with token');
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('API - Response status: ${response.statusCode}');
      final data = jsonDecode(response.body);
      print('API - Response data: $data');

      if (response.statusCode == 200) {
        return {'success': true, 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get user',
        };
      }
    } catch (e) {
      print('API - Error in getCurrentUser: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Verify Token
  Future<bool> verifyToken() async {
    try {
      // Check session token first, then persistent storage
      String? token = _sessionToken;
      if (token == null) {
        token = await storage.read(key: 'jwt_token');
      }

      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/verify-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get User Progress Stats
  Future<Map<String, dynamic>> getUserProgress() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'coursesCompleted': 0,
          'activeApplications': 0,
          'eventsParticipated': 0,
        };
      }

      // Get applications
      final applicationsResponse = await getApplications();
      int activeApplications = 0;
      if (applicationsResponse['success'] == true) {
        final applications =
            applicationsResponse['applications'] as List? ?? [];
        activeApplications = applications
            .where(
              (app) =>
                  app['status'] != 'withdrawn' && app['status'] != 'rejected',
            )
            .length;
      }

      // Get courses (completed ones would have 'course' in applications)
      int coursesCompleted = 0;
      if (applicationsResponse['success'] == true) {
        final applications =
            applicationsResponse['applications'] as List? ?? [];
        coursesCompleted = applications
            .where((app) => app['opportunity_type'] == 'course')
            .length;
      }

      // Get events (participated ones would have 'event' in applications)
      int eventsParticipated = 0;
      if (applicationsResponse['success'] == true) {
        final applications =
            applicationsResponse['applications'] as List? ?? [];
        eventsParticipated = applications
            .where((app) => app['opportunity_type'] == 'event')
            .length;
      }

      return {
        'success': true,
        'coursesCompleted': coursesCompleted,
        'activeApplications': activeApplications,
        'eventsParticipated': eventsParticipated,
      };
    } catch (e) {
      print('API - Error getting user progress: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'coursesCompleted': 0,
        'activeApplications': 0,
        'eventsParticipated': 0,
      };
    }
  }

  // ==================== NEW SIGNUP FLOW ====================

  /// Check Email Availability
  Future<Map<String, dynamic>> checkEmailAvailability(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/check-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] ?? false,
        'email_available': data['email_available'] ?? false,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'email_available': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Send Signup OTP
  Future<Map<String, dynamic>> sendSignupOTP({
    required String name,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/send-signup-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email}),
      );

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'expires_in': data['expires_in'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Verify Signup OTP
  Future<Map<String, dynamic>> verifySignupOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify-signup-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'verified': data['verified'] ?? false,
        'locked': data['locked'] ?? false,
        'expired': data['expired'] ?? false,
        'attempts_remaining': data['attempts_remaining'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Complete Signup (Set Password)
  Future<Map<String, dynamic>> completeSignup({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/complete-signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        // Store JWT token
        await storage.write(key: 'jwt_token', value: data['token']);

        // Store user data
        await storage.write(
          key: 'user_id',
          value: data['user']['id'].toString(),
        );
        await storage.write(key: 'user_name', value: data['user']['name']);
        await storage.write(key: 'user_email', value: data['user']['email']);
        await storage.write(key: 'user_role', value: data['user']['role']);

        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== PASSWORD RESET ====================

  /// Forgot Password
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'reset_token': data['reset_token'],
          'otp': data['otp_for_testing'], // For testing only
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Request failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'reset_token': resetToken,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Reset failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Logout
  Future<void> logout() async {
    print('API - Logout: Clearing all stored data');
    _sessionToken = null; // Clear session token
    await storage.deleteAll();
    print('API - Logout: All data cleared successfully');
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  /// Get stored user role
  Future<String?> getUserRole() async {
    return await storage.read(key: 'user_role');
  }

  /// Get stored user name
  Future<String?> getUserName() async {
    return await storage.read(key: 'user_name');
  }

  /// Get stored user email
  Future<String?> getUserEmail() async {
    return await storage.read(key: 'user_email');
  }

  /// Check if user is admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  // ==================== LOGIN ACTIVITY ====================

  /// Get login activity history (last 10 logins)
  Future<Map<String, dynamic>> getLoginActivity() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/login-activity'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'activities': data['activities'] ?? []};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch login activity',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Logout from all devices
  Future<Map<String, dynamic>> logoutAllDevices() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/logout-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Logged out from all devices',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to logout from all devices',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== PROFILE MANAGEMENT ====================

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
    String? bio,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'phone': phone, 'bio': bio}),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/profile/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Upload resume
  Future<Map<String, dynamic>> uploadResume(String resumeUrl) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/profile/upload-resume'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'resume_url': resumeUrl}),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get resume
  Future<Map<String, dynamic>> getResume() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/profile/resume'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Delete resume
  Future<Map<String, dynamic>> deleteResume() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/profile/resume'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Toggle two-factor authentication
  Future<Map<String, dynamic>> toggleTwoFactor({required bool enabled}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/profile/two-factor'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'enabled': enabled}),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== APPLICATIONS ====================

  /// Get user applications
  Future<Map<String, dynamic>> getApplications() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/applications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Create application
  Future<Map<String, dynamic>> createApplication({
    required String opportunityType,
    required int opportunityId,
    required String opportunityTitle,
    String? opportunityCompany,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/applications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'opportunity_type': opportunityType,
          'opportunity_id': opportunityId,
          'opportunity_title': opportunityTitle,
          'opportunity_company': opportunityCompany,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Withdraw application
  Future<Map<String, dynamic>> withdrawApplication(int applicationId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/applications/$applicationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== SAVED ITEMS ====================

  /// Get saved items
  Future<Map<String, dynamic>> getSavedItems() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/saved-items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Add saved item
  Future<Map<String, dynamic>> addSavedItem({
    required String opportunityType,
    required int opportunityId,
    required String opportunityTitle,
    String? opportunityCompany,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/saved-items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'opportunity_type': opportunityType,
          'opportunity_id': opportunityId,
          'opportunity_title': opportunityTitle,
          'opportunity_company': opportunityCompany,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Remove saved item
  Future<Map<String, dynamic>> removeSavedItem(int itemId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/saved-items/$itemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Get active sessions
  Future<Map<String, dynamic>> getActiveSessions() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/sessions/active'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Revoke a specific session
  Future<Map<String, dynamic>> revokeSession(int sessionId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/sessions/$sessionId/revoke'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Revoke all other sessions
  Future<Map<String, dynamic>> revokeAllSessions() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/sessions/revoke-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== INTERNSHIP APIs ====================

  /// Get all internships with optional filters
  Future<dynamic> getInternships({
    String? workType,
    bool? isPaid,
    String? duration,
    int? stipendMin,
    int? stipendMax,
    String? skills,
    String? company,
    String? datePosted,
    String status = 'approved',
  }) async {
    try {
      final queryParams = <String, String>{};
      if (workType != null) queryParams['work_type'] = workType;
      if (isPaid != null) queryParams['is_paid'] = isPaid.toString();
      if (duration != null) queryParams['duration'] = duration;
      if (stipendMin != null)
        queryParams['stipend_min'] = stipendMin.toString();
      if (stipendMax != null)
        queryParams['stipend_max'] = stipendMax.toString();
      if (skills != null) queryParams['skills'] = skills;
      if (company != null) queryParams['company'] = company;
      if (datePosted != null) queryParams['date_posted'] = datePosted;
      queryParams['status'] = status;

      final uri = Uri.parse(
        '$baseUrl/api/internships',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      final data = jsonDecode(response.body);
      if (data['success'] == true && data['internships'] != null) {
        return data['internships']; // Return List directly
      }
      return [];
    } catch (e) {
      print('Error loading internships: $e');
      return [];
    }
  }

  /// Get internship by ID
  Future<Map<String, dynamic>> getInternshipById(int id) async {
    try {
      final token = await _getToken();
      final headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};

      final response = await http.get(
        Uri.parse('$baseUrl/api/internships/$id'),
        headers: headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Apply to internship
  Future<Map<String, dynamic>> applyToInternship(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/internships/$id/apply'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Report internship
  Future<Map<String, dynamic>> reportInternship(int id, String reason) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/internships/$id/report'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Submit internship (user submission)
  Future<Map<String, dynamic>> submitInternship(
    Map<String, dynamic> internshipData,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/internships'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(internshipData),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== COURSE APIs ====================

  /// Get all courses with optional filters
  Future<Map<String, dynamic>> getCourses({
    String? level,
    bool? isPaid,
    String? category,
    String status = 'approved',
  }) async {
    try {
      final queryParams = <String, String>{};
      if (level != null) queryParams['level'] = level;
      if (isPaid != null) queryParams['is_paid'] = isPaid.toString();
      if (category != null) queryParams['category'] = category;
      queryParams['status'] = status;

      final uri = Uri.parse(
        '$baseUrl/api/courses',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get course by ID
  Future<Map<String, dynamic>> getCourseById(int id) async {
    try {
      final token = await _getToken();
      final headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};

      final response = await http.get(
        Uri.parse('$baseUrl/api/courses/$id'),
        headers: headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Submit course (user submission)
  Future<Map<String, dynamic>> submitCourse(
    Map<String, dynamic> courseData,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/courses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(courseData),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== EVENT APIs ====================

  /// Get all events with optional filters
  Future<Map<String, dynamic>> getEvents({
    String? eventType,
    String? category,
    String status = 'approved',
  }) async {
    try {
      final queryParams = <String, String>{};
      if (eventType != null) queryParams['event_type'] = eventType;
      if (category != null) queryParams['category'] = category;
      queryParams['status'] = status;

      final uri = Uri.parse(
        '$baseUrl/api/events',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get event by ID
  Future<Map<String, dynamic>> getEventById(int id) async {
    try {
      final token = await _getToken();
      final headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};

      final response = await http.get(
        Uri.parse('$baseUrl/api/events/$id'),
        headers: headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Submit event (user submission)
  Future<Map<String, dynamic>> submitEvent(
    Map<String, dynamic> eventData,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(eventData),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== NOTIFICATION APIs ====================

  /// Get user notifications
  Future<Map<String, dynamic>> getNotifications({int limit = 50}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications?limit=$limit'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Mark notification as read
  Future<Map<String, dynamic>> markNotificationRead(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/$id/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== RECOMMENDATIONS & TRENDING ====================

  /// Get personalized recommendations
  Future<Map<String, dynamic>> getRecommendations() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/recommendations'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get recently viewed items
  Future<Map<String, dynamic>> getRecentlyViewed({int limit = 10}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/recently-viewed?limit=$limit'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get trending opportunities
  Future<Map<String, dynamic>> getTrending({String period = 'weekly'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/trending?period=$period'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== SEARCH API ====================

  /// Global search across all content
  Future<Map<String, dynamic>> globalSearch(
    String query, {
    String? type,
  }) async {
    try {
      final queryParams = {'q': query};
      if (type != null) queryParams['type'] = type;

      final uri = Uri.parse(
        '$baseUrl/api/search',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== USER PREFERENCES APIs ====================

  /// Get user preferences (including dark mode)
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/preferences'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Update user preferences
  Future<Map<String, dynamic>> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/preferences'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(preferences),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== ADMIN APIs ====================

  /// Get admin analytics dashboard
  Future<Map<String, dynamic>> getAdminAnalytics() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/analytics'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get all users (admin only)
  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/users'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Ban/unban user (admin only)
  Future<Map<String, dynamic>> banUser(int userId, bool ban) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/users/$userId/ban'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'ban': ban}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Approve or reject content (admin only)
  Future<Map<String, dynamic>> approveContent(
    String contentType,
    int contentId,
    String action,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/content/$contentType/$contentId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'action': action}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get all reports (admin only)
  Future<Map<String, dynamic>> getReports({String status = 'pending'}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/reports?status=$status'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Resolve report (admin only)
  Future<Map<String, dynamic>> resolveReport(int reportId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/reports/$reportId/resolve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== COURSE ENROLLMENT ====================

  /// Enroll in course (track and get course link)
  Future<Map<String, dynamic>> enrollCourse(int courseId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/courses/$courseId/enroll'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== ADMIN COURSE MANAGEMENT ====================

  /// Admin adds a new course
  Future<Map<String, dynamic>> adminAddCourse(
    Map<String, dynamic> courseData,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/courses/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(courseData),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Admin updates a course
  Future<Map<String, dynamic>> adminUpdateCourse(
    int id,
    Map<String, dynamic> courseData,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/admin/courses/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(courseData),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Admin deletes a course
  Future<Map<String, dynamic>> adminDeleteCourse(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/courses/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Similar methods for internships and events

  /// Admin adds a new internship
  Future<Map<String, dynamic>> adminAddInternship(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/internships/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Admin adds a new event
  Future<Map<String, dynamic>> adminAddEvent(Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/events/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get pending submissions
  Future<Map<String, dynamic>> getPendingSubmissions() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/submissions/pending'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// View all applications (admin)
  Future<Map<String, dynamic>> adminViewApplications() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/view-applications'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
