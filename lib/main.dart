import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Attendance Admin',
      debugShowCheckedModeBanner:
          false, // Right corner ka debug banner hata diya
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(
          0xFFF4F7FE,
        ), // Modern light grey background
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const DashboardScreen(),
    );
  }
}
