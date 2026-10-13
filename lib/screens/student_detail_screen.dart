import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class StudentDetailScreen extends StatefulWidget {
  final String rollNumber;
  const StudentDetailScreen({super.key, required this.rollNumber});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _studentData = {};
  List<dynamic> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final result = await _apiService.getStudentDetail(widget.rollNumber);
    setState(() {
      if (result.isNotEmpty) {
        _studentData = result['student'] ?? {};
        _logs = result['logs'] ?? [];
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageName = _studentData['image_filename'];
    int totalClasses =
        20; // Assume total semester classes for ratio calculation
    int attended = _logs.length;
    int absent = totalClasses > attended ? totalClasses - attended : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_studentData['name'] ?? 'Student'} Profile & Analytics'),
        backgroundColor: const Color(0xFF1B2559),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Profile & Circular Pie Chart
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        // Profile Header Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
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
                                        (_studentData['name'] != null &&
                                                _studentData['name'].isNotEmpty)
                                            ? _studentData['name'][0]
                                                  .toUpperCase()
                                            : 'S',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4318FF),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _studentData['name'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B3674),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Roll No: ${_studentData['roll_number']}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4318FF,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Total: $attended',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4318FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Circular Pie Chart Container
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Attendance Ratio (Present vs Absent)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2B3674),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: _logs.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'Chart ke liye data mojood nahi hai.',
                                          ),
                                        )
                                      : PieChart(
                                          PieChartData(
                                            sectionsSpace: 4,
                                            centerSpaceRadius: 40,
                                            sections: [
                                              PieChartSectionData(
                                                color: Colors.green,
                                                value: attended.toDouble(),
                                                title: '$attended',
                                                radius: 50,
                                                titleStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              PieChartSectionData(
                                                color: Colors.redAccent,
                                                value: absent.toDouble(),
                                                title: '$absent',
                                                radius: 45,
                                                titleStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.green,
                                      size: 12,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Present',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Icon(
                                      Icons.circle,
                                      color: Colors.redAccent,
                                      size: 12,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Absent/Remaining',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Right Side: Attendance History Logs List
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Attendance History Logs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2B3674),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: _logs.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Is student ka koi attendance record nahi hai.',
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _logs.length,
                                    itemBuilder: (context, index) {
                                      final log = _logs[index];
                                      return Card(
                                        elevation: 0,
                                        color: const Color(0xFFF4F7FE),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: const Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                          ),
                                          title: Text(
                                            'Course: ${log['course_name'] ?? 'General'}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Date: ${log['date']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          trailing: Text(
                                            'Time: ${log['time']}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
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
            ),
    );
  }
}
