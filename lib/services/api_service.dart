import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL for your local FastAPI backend
  static const String baseUrl = 'http://127.0.0.1:8000/admin';

  // 1. Fetch Stats for Dashboard Cards
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }

  // 2. Fetch Weekly Attendance Counts for Chart
  Future<List<dynamic>> getWeeklyStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/weekly-stats'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Success') {
          return data['weekly_data'];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching weekly stats: $e');
      return [];
    }
  }

  // 3. Register Student with Image
  Future<Map<String, dynamic>> registerStudent({
    required String rollNumber,
    required String name,
    required dynamic imageFile, // Uint8List for Web
    required String fileName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/register-student'),
      );

      request.fields['roll_number'] = rollNumber;
      request.fields['name'] = name;

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
