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
}
