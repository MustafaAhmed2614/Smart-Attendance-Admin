import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class StudentDashboardScreen extends StatefulWidget {
  final String rollNumber;

  const StudentDashboardScreen({super.key, required this.rollNumber});

  @override
  State< StudentDashboardScreen > createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State< StudentDashboardScreen > {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String _errorMessage = '';
  String _studentName = '';
  String _selectedCourse = 'All Courses';

  List< Map< String, dynamic > > _coursesData = [];
  int _totalClasses = 0;
  int _presentCount = 0;
  int _absentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStudentAttendance();
  }

  Future< void > _loadStudentAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final res = await _apiService.getMyAttendance(widget.rollNumber);

    if (!mounted) return;

    if (res['status'] == 'Success') {
      final rawList = List< dynamic >.from(res['attendance_data'] ?? []);
      final List< Map< String, dynamic > > enrichedCourses = [];

      for (var item in rawList) {
        final courseName = (item['course_name'] ?? 'Unknown').toString();
        final records = List< dynamic >.from(item['records'] ?? []);
        final sessions = await _apiService.getCourseSessions(courseName);

        int coursePresent = 0;
        for (var rec in records) {
          final st = (rec['status'] ?? '').toString().toLowerCase();
          if (st.contains('present') && !st.contains('absent')) {
            coursePresent++;
          }
        }

        int courseTotal = sessions.length > records.length
            ? sessions.length
            : records.length;
        if (courseTotal < coursePresent) {
          courseTotal = coursePresent;
        }
        final int courseAbsent = courseTotal - coursePresent;

        enrichedCourses.add({
          'course_name': courseName,
          'records': records,
          'total': courseTotal,
          'present': coursePresent,
          'absent': courseAbsent,
        });
      }

      if (!mounted) return;
      setState(() {
        _studentName = res['student_name'] ?? widget.rollNumber;
        _coursesData = enrichedCourses;
        _isLoading = false;
      });
      _recalculateStats();
    } else {
      setState(() {
        _errorMessage = res['message'] ?? 'Unable to load student data.';
        _isLoading = false;
      });
    }
  }

  void _recalculateStats() {
    int total = 0;
    int present = 0;
    int absent = 0;

    for (var course in _coursesData) {
      if (_selectedCourse == 'All Courses' ||
          course['course_name'] == _selectedCourse) {
        total += (course['total'] as int);
        present += (course['present'] as int);
        absent += (course['absent'] as int);
      }
    }

    setState(() {
      _totalClasses = total;
      _presentCount = present;
      _absentCount = absent;
    });
  }

  Future< void > _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double percentage =
        _totalClasses > 0 ? (_presentCount / _totalClasses) * 100 : 0.0;
    final bool isLowAttendance = _totalClasses > 0 && percentage < 75.0;

    final List< String > courseNames = [
      'All Courses',
      ..._coursesData.map((c) => c['course_name'].toString()),
    ];

    final List< Map< String, dynamic > > visibleRecords = [];
    for (var course in _coursesData) {
      if (_selectedCourse == 'All Courses' ||
          course['course_name'] == _selectedCourse) {
        for (var rec in (course['records'] as List< dynamic >)) {
          visibleRecords.add({
            'course_name': course['course_name'],
            'status': rec['status'] ?? 'Present',
            'date': rec['date'] ?? '',
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 260,
            color: const Color(0xFF1B2559),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.person_pin_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Student Portal',
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  child: Text(
                    'MY COURSES',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: courseNames.length,
                    itemBuilder: (context, index) {
                      final course = courseNames[index];
                      final isSelected = course == _selectedCourse;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4318FF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Icon(
                            index == 0
                                ? Icons.dashboard_rounded
                                : Icons.book_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          title: Text(
                            course,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            setState(() => _selectedCourse = course);
                            _recalculateStats();
                          },
                        ),
                      );
                    },
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _studentName.isNotEmpty
                                      ? _studentName
                                      : 'Student',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  widget.rollNumber,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text(
                            'Logout',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, $_studentName',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B3674),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Roll Number: ${widget.rollNumber}  •  Filter: $_selectedCourse',
                                      style: const TextStyle(
                                        color: Color(0xFFA3AED0),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLowAttendance
                                        ? Colors.redAccent
                                            .withValues(alpha: 0.12)
                                        : Colors.green.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isLowAttendance
                                            ? Icons.warning_amber_rounded
                                            : Icons.verified_rounded,
                                        color: isLowAttendance
                                            ? Colors.redAccent
                                            : Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isLowAttendance
                                            ? 'Short Attendance (<75%)'
                                            : 'Good Standing (≥75%)',
                                        style: TextStyle(
                                          color: isLowAttendance
                                              ? Colors.redAccent
                                              : Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Top Metrics + Pie Chart Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left: 3 Stat Cards Stacked / Grid
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          _buildStatCard(
                                            'Total Sessions',
                                            '$_totalClasses',
                                            Icons.calendar_month_rounded,
                                            const Color(0xFF4318FF),
                                          ),
                                          const SizedBox(width: 16),
                                          _buildStatCard(
                                            'Present',
                                            '$_presentCount',
                                            Icons.check_circle_rounded,
                                            Colors.green,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          _buildStatCard(
                                            'Absent',
                                            '$_absentCount',
                                            Icons.cancel_rounded,
                                            Colors.redAccent,
                                          ),
                                          const SizedBox(width: 16),
                                          _buildStatCard(
                                            'Attendance Rate',
                                            '${percentage.toStringAsFixed(1)}%',
                                            Icons.pie_chart_rounded,
                                            isLowAttendance
                                                ? Colors.orange
                                                : const Color(0xFF4318FF),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),

                                // Right: Custom Pie/Donut Chart Card
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 216,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 140,
                                          height: 140,
                                          child: CustomPaint(
                                            painter: _AttendancePiePainter(
                                              present: _presentCount,
                                              absent: _absentCount,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${percentage.toStringAsFixed(0)}%',
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2B3674),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Attendance Ratio',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2B3674),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              _buildLegendItem(
                                                Colors.green,
                                                'Present ($_presentCount)',
                                              ),
                                              const SizedBox(height: 10),
                                              _buildLegendItem(
                                                Colors.redAccent,
                                                'Absent ($_absentCount)',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Bottom: Attendance Logs List
                            const Text(
                              'Attendance History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2B3674),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: visibleRecords.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No attendance records available yet.',
                                          style: TextStyle(
                                            color: Color(0xFFA3AED0),
                                            fontSize: 15,
                                          ),
                                        ),
                                      )
                                    : ListView.separated(
                                        itemCount: visibleRecords.length,
                                        separatorBuilder: (_, __) =>
                                            const Divider(height: 1),
                                        itemBuilder: (context, index) {
                                          final rec = visibleRecords[index];
                                          final statusStr =
                                              rec['status'].toString();
                                          final isPresent = statusStr
                                                  .toLowerCase()
                                                  .contains('present') &&
                                              !statusStr
                                                  .toLowerCase()
                                                  .contains('absent');

                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: isPresent
                                                  ? Colors.green
                                                      .withValues(alpha: 0.12)
                                                  : Colors.redAccent
                                                      .withValues(alpha: 0.12),
                                              child: Icon(
                                                isPresent
                                                    ? Icons.check_rounded
                                                    : Icons.close_rounded,
                                                color: isPresent
                                                    ? Colors.green
                                                    : Colors.redAccent,
                                              ),
                                            ),
                                            title: Text(
                                              rec['course_name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2B3674),
                                              ),
                                            ),
                                            subtitle: Text(
                                              'Date & Time: ${rec['date']}',
                                              style: const TextStyle(
                                                color: Color(0xFFA3AED0),
                                              ),
                                            ),
                                            trailing: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isPresent
                                                    ? Colors.green
                                                        .withValues(alpha: 0.12)
                                                    : Colors.redAccent
                                                        .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                statusStr,
                                                style: TextStyle(
                                                  color: isPresent
                                                      ? Colors.green
                                                      : Colors.redAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFA3AED0),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B3674),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2B3674),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AttendancePiePainter extends CustomPainter {
  final int present;
  final int absent;

  _AttendancePiePainter({required this.present, required this.absent});

  @override
  void paint(Canvas canvas, Size size) {
    final total = present + absent;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const strokeWidth = 18.0;

    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    if (total == 0) return;

    final presentSweep = (present / total) * 2 * math.pi;
    final absentSweep = (absent / total) * 2 * math.pi;

    final presentPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final absentPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;

    if (present > 0) {
      canvas.drawArc(rect, startAngle, presentSweep, false, presentPaint);
    }
    if (absent > 0) {
      canvas.drawArc(
        rect,
        startAngle + presentSweep,
        absentSweep,
        false,
        absentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AttendancePiePainter oldDelegate) {
    return oldDelegate.present != present || oldDelegate.absent != absent;
  }
}