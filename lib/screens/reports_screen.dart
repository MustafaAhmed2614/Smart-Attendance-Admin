import 'package:flutter/material.dart';
import 'dart:html' as html; // Flutter Web ke liye direct download
import '../widgets/sidebar.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _reports = [];
  List<dynamic> _filteredReports = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReports();
    _searchController.addListener(_filterReports);
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getAttendanceReports();
    setState(() {
      _reports = data;
      _filteredReports = data;
      _isLoading = false;
    });
  }

  void _filterReports() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReports = _reports.where((report) {
        final name = (report['name'] ?? '').toString().toLowerCase();
        final rollNo = (report['roll_number'] ?? '').toString().toLowerCase();
        return name.contains(query) || rollNo.contains(query);
      }).toList();
    });
  }

  // CSV Export Function for Web
  void _downloadCsv() {
    final String url = 'http://127.0.0.1:8000/export-attendance/';
    html.window.open(url, '_blank');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  // Header Row with Title and Export Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Attendance Reports & Logs',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B3674),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _downloadCsv,
                        icon: const Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Export to CSV',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4318FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by Student Name or Roll Number...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF4318FF),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reports List Area
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredReports.isEmpty
                        ? const Center(
                            child: Text('Koi attendance record nahi mila.'),
                          )
                        : Container(
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
                              itemCount: _filteredReports.length,
                              itemBuilder: (context, index) {
                                final report = _filteredReports[index];
                                return ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFF4318FF),
                                    child: Icon(
                                      Icons.assignment_turned_in,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    report['name'] ?? 'Unknown Student',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2B3674),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Roll Number: ${report['roll_number']} | Course: ${report['course_name'] ?? report['course'] ?? report['subject'] ?? 'General'}',
                                  ),
                                  trailing: Text(
                                    'Date: ${report['date']}\nTime: ${report['time']}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
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
