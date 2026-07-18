import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/stat_card.dart';
import '../widgets/attendance_chart.dart';
import '../services/api_service.dart'; // Naya import API ke liye

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    // Screen load hotay hi API call initialize ho jayegi
    _statsFuture = _apiService.getDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          const Sidebar(),

          // Main Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B3674),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // FutureBuilder for dynamic API data
                  FutureBuilder<Map<String, dynamic>>(
                    future: _statsFuture,
                    builder: (context, snapshot) {
                      // 1. Loading State
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      // 2. Error State
                      else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: Text(
                              'Error loading data: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      }
                      // 3. Success State (Data received)
                      else if (snapshot.hasData) {
                        final data = snapshot.data!;
                        final int totalStudents = data['total_students'] ?? 0;
                        final int presentToday = data['present_today'] ?? 0;
                        final int absentToday =
                            totalStudents - presentToday; // Calculating absents

                        return Row(
                          children: [
                            StatCard(
                              title: 'Total Students',
                              value: totalStudents.toString(),
                              icon: Icons.school_rounded,
                              iconColor: Colors.blueAccent,
                              iconBgColor: Colors.blue.withOpacity(0.1),
                            ),
                            const SizedBox(width: 20),
                            StatCard(
                              title: 'Present Today',
                              value: presentToday.toString(),
                              icon: Icons.check_circle_rounded,
                              iconColor: Colors.green,
                              iconBgColor: Colors.green.withOpacity(0.1),
                            ),
                            const SizedBox(width: 20),
                            StatCard(
                              title: 'Absent Today',
                              value: absentToday.toString(),
                              icon: Icons.cancel_rounded,
                              iconColor: Colors.redAccent,
                              iconBgColor: Colors.red.withOpacity(0.1),
                            ),
                          ],
                        );
                      }

                      // Fallback
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 30),

                  // Attendance Chart
                  const AttendanceChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
