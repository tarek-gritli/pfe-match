import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/pfe_listing.dart';
import 'token_service.dart';

class MatchResult {
  final double matchScore;
  final String explanation;
  final Map<String, dynamic>? details;

  MatchResult({
    required this.matchScore,
    required this.explanation,
    this.details,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      matchScore: (json['matchScore'] ?? 0).toDouble(),
      explanation: json['explanation'] ?? '',
      details: json['details'],
    );
  }
}

class ApplicationResponse {
  final String id;
  final String message;
  final double matchScore;

  ApplicationResponse({
    required this.id,
    required this.message,
    required this.matchScore,
  });

  factory ApplicationResponse.fromJson(Map<String, dynamic> json) {
    return ApplicationResponse(
      id: json['id']?.toString() ?? '',
      message: json['message'] ?? '',
      matchScore: (json['matchScore'] ?? 0).toDouble(),
    );
  }
}

class PFEService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get all PFE listings for exploration
  Future<List<PFEListing>> getExplorePFEs() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/pfe/explore'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - server took too long to respond');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PFEListing.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load PFE listings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching PFE listings: $e');
    }
  }

  /// Get a specific PFE listing by ID
  Future<PFEListing> getPFEById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/pfe/listings/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return PFEListing.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('PFE listing not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load PFE: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching PFE: $e');
    }
  }

  /// Get match preview for a PFE listing (without applying)
  Future<MatchResult> getMatchPreview(String pfeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/pfe/listings/$pfeId/match-preview'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return MatchResult.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to get match preview: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting match preview: $e');
    }
  }

  /// Apply to a PFE listing
  Future<ApplicationResponse> applyToPFE(String pfeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/pfe/listings/$pfeId/apply'),
        headers: headers,
        body: json.encode({}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return ApplicationResponse.fromJson(responseData);
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Application failed');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to apply: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error applying to PFE: $e');
    }
  }

  /// Get all PFE listings (for enterprise)
  Future<List<PFEListing>> getAllPFEListings() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/pfe/listings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PFEListing.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load PFE listings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching PFE listings: $e');
    }
  }

  /// Create a new PFE listing (for enterprise)
  Future<PFEListing> createPFEListing(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/pfe/listings'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PFEListing.fromJson(json.decode(response.body));
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create PFE');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to create PFE: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating PFE: $e');
    }
  }
}
