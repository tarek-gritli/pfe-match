import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class AuthService {
  Future<Map<String, dynamic>> registerStudent({
    required String firstName,
    required String lastName,
    required String email,
    required String university,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.registerStudent),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode({
              'first_name': firstName,
              'last_name': lastName,
              'email': email,
              'university': university,
              'password': password,
              'user_type': 'student',
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else if (response.statusCode == 409) {
        throw Exception(responseData['detail'] ?? 'Email already registered');
      } else {
        throw Exception(responseData['detail'] ?? 'Registration failed');
      }
    } on SocketException {
      throw Exception(
        'Connection failed. Please check your internet connection.',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Invalid response from server.');
    }
  }

  Future<Map<String, dynamic>> registerEnterprise({
    required String companyName,
    required String email,
    required String industry,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.registerEnterprise),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode({
              'company_name': companyName,
              'email': email,
              'industry': industry,
              'password': password,
              'user_type': 'enterprise',
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else if (response.statusCode == 409) {
        throw Exception(responseData['detail'] ?? 'Email already registered');
      } else {
        throw Exception(responseData['detail'] ?? 'Registration failed');
      }
    } on SocketException {
      throw Exception(
        'Connection failed. Please check your internet connection.',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Invalid response from server.');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 401) {
        throw Exception(responseData['detail'] ?? 'Invalid email or password');
      } else if (response.statusCode == 403) {
        throw Exception(responseData['detail'] ?? 'Account is inactive');
      } else {
        throw Exception(responseData['detail'] ?? 'Login failed');
      }
    } on SocketException {
      throw Exception(
        'Connection failed. Please check your internet connection.',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Invalid response from server.');
    }
  }

  Future<void> logout(String token) async {
    try {
      await http.post(
        Uri.parse(ApiConfig.logout),
        headers: ApiConfig.authHeaders(token),
      );
    } catch (e) {
      // Silently fail logout
    }
  }

  Future<void> signInWithGoogle() async {
    throw UnimplementedError('Google Sign-In not implemented');
  }
}
