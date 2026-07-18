import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // Main container for the sidebar with a dark theme
    return Container(
      width: 260,
      color: const Color(0xFF111C44),
      child: Column(
        children: [
          const SizedBox(height: 50),

          // Project Title / Logo Area
          const Text(
            'Smart Attendance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 60),

          // Navigation Menu Items
          _buildNavItem(Icons.dashboard_rounded, 'Dashboard', true),
          _buildNavItem(Icons.people_alt_rounded, 'Manage Students', false),
          _buildNavItem(Icons.bar_chart_rounded, 'Reports', false),

          const Spacer(), // Pushes the settings item to the bottom
          // Bottom Settings Item
          _buildNavItem(Icons.settings_rounded, 'Settings', false),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Helper widget to create consistent navigation links
  Widget _buildNavItem(IconData icon, String title, bool isActive) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.white : Colors.white54),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        hoverColor: Colors.white10,
        onTap: () {
          // TODO: Implement navigation logic when other screens are ready
        },
      ),
    );
  }
}
