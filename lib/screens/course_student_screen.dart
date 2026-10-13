import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'student_detail_screen.dart';

class CourseStudentsScreen extends StatefulWidget {
  final String courseName;
  const CourseStudentsScreen({super.key, required this.courseName});

  @override
  State<CourseStudentsScreen> createState() => _CourseStudentsScreenState();
}

class _CourseStudentsScreenState extends State<CourseStudentsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final students = await _apiService.getCourseStudents(widget.courseName);
    setState(() {
      _students = students;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students in ${widget.courseName}'),
        backgroundColor: const Color(0xFF1B2559),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(30.0),
              child: _students.isEmpty
                  ? const Center(
                      child: Text(
                        'Is course mein koi student enrolled nahi hai.',
                      ),
                    )
                  : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        final imageName = student['image_filename'];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentDetailScreen(
                                    rollNumber: student['roll_number'],
                                  ),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: const Color(
                                0xFF4318FF,
                              ).withOpacity(0.1),
                              backgroundImage: imageName != null
                                  ? NetworkImage(
                                      'http://127.0.0.1:8000/admin/student-images/$imageName',
                                    )
                                  : null,
                              child: imageName == null
                                  ? Text(
                                      (student['name'] != null &&
                                              student['name'].isNotEmpty)
                                          ? student['name'][0].toUpperCase()
                                          : 'S',
                                      style: const TextStyle(
                                        color: Color(0xFF4318FF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              student['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Roll Number: ${student['roll_number']}',
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
