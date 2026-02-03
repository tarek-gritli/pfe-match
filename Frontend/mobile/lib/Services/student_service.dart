import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../core/config/api_config.dart';
import 'token_service.dart';

class StudentService {
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated - no token found');
    }
    return ApiConfig.authHeaders(token);
  }

  Future<Student> getMyProfile() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(ApiConfig.studentProfile),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print("body");
      print(response.body);
      // FIX: Convert JSON to Student object before returning
      return Student.fromJson(jsonData);
    } else {
      String errorMessage = 'Failed to load profile: ${response.statusCode}';
      try {
        final errorData = json.decode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'].toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> updateMyProfile(
    Map<String, dynamic> updates,
  ) async {
    final headers = await _getAuthHeaders();

    final response = await http.put(
      Uri.parse(ApiConfig.updateProfile),
      headers: headers,
      body: json.encode(updates),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      String errorMessage = 'Failed to update profile: ${response.statusCode}';
      try {
        final errorData = json.decode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'].toString();
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'].toString();
        }
      } catch (_) {
        errorMessage = 'Failed to update profile: ${response.statusCode}';
      }
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> uploadResume(File file) async {
    final token = await TokenService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.uploadResume),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
  String errorMessage = 'Failed to upload profile picture: ${response.statusCode}';
  try {
    final errorData = json.decode(response.body);
    if (errorData['detail'] != null) {
      errorMessage = errorData['detail'].toString();
    } else if (errorData['message'] != null) {
      errorMessage = errorData['message'].toString();
    }
  } catch (_) {}
  throw Exception(errorMessage);
}
  }

  Future<Map<String, dynamic>> uploadStudentProfilePicture(File file) async {
  final token = await TokenService.getToken();
  if (token == null || token.isEmpty) {
    throw Exception('Not authenticated');
  }

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(ApiConfig.uploadProfilePicture),
  );

  request.headers['Authorization'] = 'Bearer $token';

  // Set proper content type
  final fileName = file.path.split(Platform.pathSeparator).last;
  final mimeType = fileName.endsWith('.png')
      ? 'image/png'
      : fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')
          ? 'image/jpeg'
          : fileName.endsWith('.gif')
              ? 'image/gif'
              : fileName.endsWith('.webp')
                  ? 'image/webp'
                  : 'application/octet-stream';

  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: fileName,
      contentType: http.MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
    ),
  );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    // try to parse backend error message
    String errorMessage = 'Failed to upload profile picture: ${response.statusCode}';
    try {
      final errorData = json.decode(response.body);
      if (errorData['detail'] != null) {
        errorMessage = errorData['detail'].toString();
      } else if (errorData['message'] != null) {
        errorMessage = errorData['message'].toString();
      }
    } catch (_) {}
    throw Exception(errorMessage);
  }
}

String getProfileImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    // If it's already a full URL, return as-is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Remove leading slash if present
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    String baseUrl = ApiConfig.baseUrl;
    return '$baseUrl/$cleanPath';
  }

}
