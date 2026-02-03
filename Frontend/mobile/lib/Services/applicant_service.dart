import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/student_application.dart';
import 'token_service.dart';

class ApplicantService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get all applications for the current student
  Future<List<StudentApplication>> getMyApplications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/pfe/applications/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StudentApplication.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load applications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching applications: $e');
    }
  }

  /// Get a specific application by ID
  Future<StudentApplication> getApplicationById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/pfe/applications/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return StudentApplication.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Application not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load application: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching application: $e');
    }
  }
}
