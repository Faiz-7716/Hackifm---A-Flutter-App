import 'package:flutter/foundation.dart';
import 'package:hackifm/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isAuthenticated = false;
  bool _isAdmin = false;
  String? _userName;
  String? _userEmail;
  String? _userRole;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _isAdmin;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;

  /// Initialize auth state from storage
  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _apiService.isLoggedIn();
      if (isLoggedIn) {
        final isValid = await _apiService.verifyToken();
        if (isValid) {
          _isAuthenticated = true;
          _userName = await _apiService.getUserName();
          _userEmail = await _apiService.getUserEmail();
          _userRole = await _apiService.getUserRole();
          _isAdmin = _userRole == 'admin';
        } else {
          await logout();
        }
      }
    } catch (e) {
      debugPrint('Auth init error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login
  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    if (result['success']) {
      _isAuthenticated = true;
      _userName = result['user']['name'];
      _userEmail = result['user']['email'];
      _userRole = result['user']['role'];
      _isAdmin = _userRole == 'admin';
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  /// Signup
  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.signup(
      name: name,
      email: email,
      password: password,
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }

  /// Login with token (used after signup)
  Future<void> loginWithToken(String token, Map<String, dynamic> user) async {
    _isAuthenticated = true;
    _userName = user['name'];
    _userEmail = user['email'];
    _userRole = user['role'];
    _isAdmin = _userRole == 'admin';
    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    await _apiService.logout();
    _isAuthenticated = false;
    _isAdmin = false;
    _userName = null;
    _userEmail = null;
    _userRole = null;
    notifyListeners();
  }

  /// Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await _apiService.forgotPassword(email: email);
  }

  /// Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String resetToken,
    required String newPassword,
  }) async {
    return await _apiService.resetPassword(
      email: email,
      otp: otp,
      resetToken: resetToken,
      newPassword: newPassword,
    );
  }
}
