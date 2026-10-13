import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../services/api_service.dart';
import 'student_detail_screen.dart';

class DefaultersScreen extends StatefulWidget {
  const DefaultersScreen({super.key});

  @override
  State<DefaultersScreen> createState() => _DefaultersScreenState();
}

class _DefaultersScreenState extends State<DefaultersScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _defaulters = [];

  @override
  void initState() {
    super.initState();
    _loadDefaulters();
  }

  Future<void> _loadDefaulters() async {
    final defaulters = await _apiService.getDefaulters();
    setState(() {
      _defaulters = defaulters;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Low Attendance Defaulters',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B3674),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Students with critical or low attendance records.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _defaulters.isEmpty
                        ? const Center(
                            child: Text(
                              'Zabardast! Koi low attendance defaulter mojood nahi hai.',
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              itemCount: _defaulters.length,
                              itemBuilder: (context, index) {
                                final student = _defaulters[index];
                                final imageName = student['image_filename'];

                                return ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            StudentDetailScreen(
                                              rollNumber:
                                                  student['roll_number'],
                                            ),
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.red.withOpacity(
                                      0.1,
                                    ),
                                    backgroundImage: imageName != null
                                        ? NetworkImage(
                                            'http://127.0.0.1:8000/admin/student-images/$imageName',
                                          )
                                        : null,
                                    child: imageName == null
                                        ? Text(
                                            student['name'][0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    student['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2B3674),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Roll Number: ${student['roll_number']}',
                                  ),
                                  trailing: Chip(
                                    label: Text(
                                      'Classes Attended: ${student['attendance_count']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
