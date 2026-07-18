import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF111C44),
      child: Column(
        children: [
          const SizedBox(height: 50),

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

          // YAHAN FIX KIYA HAI: Har item mein pehla argument 'context' pass kar diya
          _buildNavItem(context, Icons.dashboard_rounded, 'Dashboard', true),
          _buildNavItem(
            context,
            Icons.people_alt_rounded,
            'Manage Students',
            false,
          ),
          _buildNavItem(context, Icons.bar_chart_rounded, 'Reports', false),

          const Spacer(),

          _buildNavItem(context, Icons.settings_rounded, 'Settings', false),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Helper widget update kar diya tha humne
  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isActive,
  ) {
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
          // Navigation Logic
          if (title == 'Dashboard') {
            Navigator.pushReplacementNamed(context, '/');
          } else if (title == 'Manage Students') {
            Navigator.pushReplacementNamed(context, '/manage');
          }
        },
      ),
    );
  }
}
