import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Change this to your backend URL
  // For local testing: http://localhost:5000 (web) or http://10.0.2.2:5000 (android emulator)
  static const String baseUrl = 'http://localhost:5000';

  final storage = const FlutterSecureStorage();

  // ==================== AUTHENTICATION ====================

  /// User Signup
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (rememberMe) {
          // Store JWT token and user data only if "Remember Me" is checked
          await storage.write(key: 'jwt_token', value: data['token']);

          // Store user data
          await storage.write(
            key: 'user_id',
            value: data['user']['id'].toString(),
          );
          await storage.write(key: 'user_name', value: data['user']['name']);
          await storage.write(key: 'user_email', value: data['user']['email']);
          await storage.write(key: 'user_role', value: data['user']['role']);

          // Mark that user chose to be remembered
          await storage.write(key: 'remember_me', value: 'true');
        } else {
          // For this session only - don't persist credentials
          // Clear any existing stored credentials
          await storage.delete(key: 'jwt_token');
          await storage.delete(key: 'user_id');
          await storage.delete(key: 'user_name');
          await storage.delete(key: 'user_email');
          await storage.delete(key: 'user_role');
          await storage.delete(key: 'remember_me');
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
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get user',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Verify Token
  Future<bool> verifyToken() async {
    try {
      final token = await storage.read(key: 'jwt_token');

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
    await storage.deleteAll();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
      final token = await storage.read(key: 'jwt_token');
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
}
