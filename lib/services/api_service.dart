import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL for local FastAPI backend
  static const String baseUrl = 'http://127.0.0.1:8000/admin';

  // 1. Fetch Dashboard Stats
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

  // 3. Fetch All Students List
  Future<List<dynamic>> getStudents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/students'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Success') {
          return data['students'];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  // 4. Fetch Attendance Reports Logs
  Future<List<dynamic>> getAttendanceReports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reports'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching reports: $e');
      return [];
    }
  }

  // 5. Fetch Individual Student Detail & Logs
  Future<Map<String, dynamic>> getStudentDetail(String rollNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student-detail/$rollNumber'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data;
        }
      }
      return {};
    } catch (e) {
      print('Error fetching student detail: $e');
      return {};
    }
  }

  // 6. Register Student with Image
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

  // 7. Fetch All Courses (Inside Class)
  Future<List<dynamic>> getCourses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/courses'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['courses'];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  // 8. Fetch Students Enrolled in a Specific Course (Inside Class)
  Future<List<dynamic>> getCourseStudents(String courseName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/course-students/$courseName'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['students'];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching course students: $e');
      return [];
    }
  }
}
