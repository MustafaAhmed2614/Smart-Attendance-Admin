import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../services/api_service.dart';
import 'student_detail_screen.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _apiService.getStudents();
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
                    'Registered Students List',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B3674),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: _studentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('Koi student registered nahi hai.'),
                          );
                        }

                        final students = snapshot.data!;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                spreadRadius: 2,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              final imageName = student['image_filename'];

                              return ListTile(
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
                                    color: Color(0xFF2B3674),
                                  ),
                                ),
                                subtitle: Text(
                                  'Roll Number: ${student['roll_number']}',
                                ),
                                trailing: Chip(
                                  label: Text(
                                    student['face_status'] ?? 'Registered',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        );
                      },
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
