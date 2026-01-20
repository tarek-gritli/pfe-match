import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/student.dart';

class StudentService {
  static const String baseUrl = 'http://localhost:8000'; // Adjust port if needed

  Future<Student> getMyProfile() async {
  final response = await http.get(Uri.parse('$baseUrl/students/me'));
  
  if (response.statusCode == 200) {
    print('Response body: ${response.body}');  // Add this for debugging
    final jsonData = json.decode(response.body);
    print('Parsed JSON: $jsonData');  // Add this for debugging
    return Student.fromJson(jsonData);
  } else {
    throw Exception('Failed to load profile: ${response.statusCode}');
  }
}

  Future<Student> updateMyProfile(Map<String, dynamic> updates) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/me'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Student.fromJson(data['data']);
    } else {
      throw Exception('Failed to update profile');
    }
  }
}