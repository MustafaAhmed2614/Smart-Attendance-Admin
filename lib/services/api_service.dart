import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL for your local FastAPI backend
  // Note: 127.0.0.1 is standard for localhost testing
  static const String baseUrl = 'http://127.0.0.1:8000/admin';

  // Function to fetch stats from /admin/stats endpoint
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats'));

      if (response.statusCode == 200) {
        // Successfully connected and fetched data
        return json.decode(response.body);
      } else {
        // Backend returned an error code
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      // Network error or server is down
      throw Exception('Error connecting to backend: $e');
    }
  }

  // Function to register a new student with image
  Future<Map<String, dynamic>> registerStudent({
    required String rollNumber,
    required String name,
    required dynamic imageFile, // Uint8Bytes for Flutter Web compatibility
    required String fileName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/register-student'),
      );

      // Adding text fields
      request.fields['roll_number'] = rollNumber;
      request.fields['name'] = name;

      // Adding image file for web
      request.files.add(
        http.MultipartFile.fromBytes('image', imageFile, filename: fileName),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to register student: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }
}
