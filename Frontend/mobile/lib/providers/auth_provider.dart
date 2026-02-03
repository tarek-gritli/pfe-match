import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import '../Services/token_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  String? _userType;
  bool _profileCompleted = false;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String? get userType => _userType;
  bool get profileCompleted => _profileCompleted;
  Map<String, dynamic>? get user => _user;

  Future<bool> registerStudent({
    required String firstName,
    required String lastName,
    required String email,
    required String university,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.registerStudent(
        firstName: firstName,
        lastName: lastName,
        email: email,
        university: university,
        password: password,
      );

      // Save tokens if returned
      if (response['access_token'] != null) {
        await TokenService.saveToken(response['access_token']);
      }
      if (response['refresh_token'] != null) {
        await TokenService.saveRefreshToken(response['refresh_token']);
      }

      _isAuthenticated = true;
      _userType = 'student';
      _profileCompleted = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerEnterprise({
    required String companyName,
    required String email,
    required String industry,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.registerEnterprise(
        companyName: companyName,
        email: email,
        industry: industry,
        password: password,
      );

      // Save tokens if returned
      if (response['access_token'] != null) {
        await TokenService.saveToken(response['access_token']);
      }
      if (response['refresh_token'] != null) {
        await TokenService.saveRefreshToken(response['refresh_token']);
      }

      _isAuthenticated = true;
      _userType = 'enterprise';
      _profileCompleted = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      // Save tokens
      if (response['access_token'] != null) {
        await TokenService.saveToken(response['access_token']);      }
      if (response['refresh_token'] != null) {
        await TokenService.saveRefreshToken(response['refresh_token']);
      }

      _userType = response['user_type'];
      _profileCompleted = response['profile_completed'] ?? false;
      _user = {'email': email, 'user_type': response['user_type']};
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await TokenService.clearTokens();
    _isAuthenticated = false;
    _userType = null;
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    final isLoggedIn = await TokenService.isLoggedIn();
    _isAuthenticated = isLoggedIn;
    notifyListeners();
    return isLoggedIn;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setProfileCompleted(bool completed) {
    _profileCompleted = completed;
    notifyListeners();
  }
}
