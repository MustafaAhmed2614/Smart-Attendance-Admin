import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/manage_students_screen.dart';
import '../screens/students_list_screen.dart'; // Nayi screen ka import
import '../screens/reports_screen.dart';
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: const Color(0xFF1B2559), // Professional Dark Navy Blue
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo / Title Header
          const Padding(
            padding: EdgeInsets.all(30.0),
            child: Text(
              'Smart Attendance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),

          // Navigation Links
          ListTile(
            leading: const Icon(Icons.dashboard_rounded, color: Colors.white70),
            title: const Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.person_add_rounded,
              color: Colors.white70,
            ),
            title: const Text(
              'Manage Students',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageStudentsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.people_alt_rounded,
              color: Colors.white70,
            ),
            title: const Text(
              'All Students',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentsListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_rounded, color: Colors.white70),
            title: const Text(
              'Reports',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ReportsScreen()),
              );
            },
          ),

          const Spacer(),

          // Bottom Settings / Logout area (Optional)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Admin Panel v1.0',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
