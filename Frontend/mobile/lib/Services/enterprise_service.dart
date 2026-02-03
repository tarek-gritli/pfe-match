import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/enterprise.dart';
import '../../core/config/api_config.dart';
import 'token_service.dart';
import 'dart:io';


class EnterpriseService {
  /// Get auth headers with bearer token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated - no token found');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Fetch current enterprise profile
  Future<Enterprise> getMyProfile() async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse(ApiConfig.enterpriseProfile), // points to /enterprises/me
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return Enterprise.fromJson(jsonData);
    } else {
      // Try to parse error detail
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
    Uri.parse(ApiConfig.updateEnterpriseProfile), // points to /enterprises/me/profile
    headers: headers,
    body: json.encode(updates),
  );

  if (response.statusCode == 200) {
    // Backend returns a message response: { "message": "Profile updated successfully" }
    return json.decode(response.body);
  } else {
    String errorMessage =
        'Failed to update profile: ${response.statusCode}';
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

Future<Map<String, dynamic>> uploadLogo(File file) async {
    final token = await TokenService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.uploadEnterpriseLogo), // points to /enterprises/me/logo
    );

    request.headers['Authorization'] = 'Bearer $token';

    // Determine mime type based on file extension
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
        'file', // backend expects 'file' as the key
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
      String errorMessage = 'Failed to upload logo: ${response.statusCode}';
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

  String getLogoUrl(String? path) {
  if (path == null || path.isEmpty) return '';

  // If it's already a full URL, return as-is
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path;
  }

  // Remove leading slash if present
  final cleanPath = path.startsWith('/') ? path.substring(1) : path;

  return '${ApiConfig.baseUrl}/$cleanPath';
}


}
