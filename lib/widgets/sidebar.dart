import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/students_list_screen.dart';
import '../screens/courses_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/defaulter_screen.dart'; // 👈 Defaulters screen import

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF1B2559),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo / Title Header
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              children: const [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Admin Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  destination: const DashboardScreen(),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.people_alt_rounded,
                  title: 'Students List',
                  destination: const StudentsListScreen(),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.book_rounded,
                  title: 'Courses',
                  destination: const CoursesScreen(),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.assessment_rounded,
                  title: 'Attendance Reports',
                  destination: const ReportsScreen(),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.warning_amber_rounded,
                  title: 'Defaulters',
                  destination: const DefaultersScreen(),
                ),
              ],
            ),
          ),

          // Bottom Logout / Footer Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  'Admin User',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for sidebar items navigation
  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget destination,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }
}
