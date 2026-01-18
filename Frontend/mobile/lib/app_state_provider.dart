import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider extends ChangeNotifier {
  // Authentication state
  bool _isSignedIn = false;
  String? _userId;
  String? _userEmail;
  String? _userName;

  // Theme state
  ThemeMode _themeMode = ThemeMode.system;

  // User type (student or company)
  UserType _userType = UserType.student;

  // Getters
  bool get isSignedIn => _isSignedIn;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  ThemeMode get themeMode => _themeMode;
  UserType get userType => _userType;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Initialize and load saved preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load authentication state
    _isSignedIn = prefs.getBool('isSignedIn') ?? false;
    _userId = prefs.getString('userId');
    _userEmail = prefs.getString('userEmail');
    _userName = prefs.getString('userName');
    
    // Load theme preference
    final themeModeString = prefs.getString('themeMode') ?? 'system';
    _themeMode = _parseThemeMode(themeModeString);
    
    // Load user type
    final userTypeString = prefs.getString('userType') ?? 'student';
    _userType = userTypeString == 'company' ? UserType.company : UserType.student;
    
    notifyListeners();
  }

  // Authentication methods
  Future<void> signIn({
    required String userId,
    required String email,
    required String name,
    required UserType userType,
  }) async {
    _isSignedIn = true;
    _userId = userId;
    _userEmail = email;
    _userName = name;
    _userType = userType;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignedIn', true);
    await prefs.setString('userId', userId);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', name);
    await prefs.setString('userType', userType == UserType.company ? 'company' : 'student');

    notifyListeners();
  }

  Future<void> signOut() async {
    _isSignedIn = false;
    _userId = null;
    _userEmail = null;
    _userName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignedIn', false);
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    await prefs.remove('userType');

    notifyListeners();
  }

  // Theme methods
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeModeToString(mode));
    
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  // User type methods
  Future<void> setUserType(UserType type) async {
    _userType = type;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', type == UserType.company ? 'company' : 'student');
    
    notifyListeners();
  }

  // Helper methods
  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}

enum UserType {
  student,
  company,
}