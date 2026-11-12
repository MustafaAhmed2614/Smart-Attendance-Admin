import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class TeacherDashboardScreen extends StatefulWidget {
  final String username;

  const TeacherDashboardScreen({super.key, required this.username});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final ApiService _apiService = ApiService();

  List<String> _courses = [];
  String? _selectedCourse;

  List<String> _sessions = [];
  String _selectedDate = DateTime.now().toIso8601String().split('T')[0];

  List<dynamic> _attendanceList = [];
  bool _isLoadingCourses = true;
  bool _isLoadingAttendance = false;

  @override
  void initState() {
    super.initState();
    _loadTeacherCourses();
  }

  Future<void> _loadTeacherCourses() async {
    setState(() => _isLoadingCourses = true);
    final courses = await _apiService.getTeacherCourses(widget.username);

    if (!mounted) return;
    setState(() {
      _courses = courses;
      _isLoadingCourses = false;
      if (_courses.isNotEmpty) {
        _selectedCourse = _courses.first;
      }
    });

    if (_selectedCourse != null) {
      await _loadCourseSessionsAndAttendance(_selectedCourse!);
    }
  }

  Future<void> _loadCourseSessionsAndAttendance(String courseName) async {
    setState(() => _isLoadingAttendance = true);

    final today = DateTime.now().toIso8601String().split('T')[0];
    final sessions = await _apiService.getCourseSessions(courseName);

    final Set<String> uniqueDates = {today, ...sessions};
    final dateList = uniqueDates.toList()..sort((a, b) => b.compareTo(a));

    final targetDate = dateList.contains(_selectedDate) ? _selectedDate : today;
    final attendanceRes = await _apiService.getAttendanceByDate(
      courseName,
      targetDate,
    );

    if (!mounted) return;
    setState(() {
      _sessions = dateList;
      _selectedDate = targetDate;
      _attendanceList = attendanceRes['attendance_list'] ?? [];
      _isLoadingAttendance = false;
    });
  }

  Future<void> _onDateChanged(String newDate) async {
    if (_selectedCourse == null) return;
    setState(() {
      _selectedDate = newDate;
      _isLoadingAttendance = true;
    });

    final attendanceRes = await _apiService.getAttendanceByDate(
      _selectedCourse!,
      newDate,
    );

    if (!mounted) return;
    setState(() {
      _attendanceList = attendanceRes['attendance_list'] ?? [];
      _isLoadingAttendance = false;
    });
  }

  Future<void> _toggleStatus(int index, String currentStatus) async {
    if (_selectedCourse == null) return;
    final student = _attendanceList[index];
    final newStatus = currentStatus == 'Present' ? 'Absent' : 'Present';

    // Optimistic UI update
    setState(() {
      _attendanceList[index]['status'] = newStatus;
    });

    final res = await _apiService.toggleManualAttendance(
      rollNumber: student['roll_number'],
      courseName: _selectedCourse!,
      status: newStatus,
      date: _selectedDate,
    );

    if (!mounted) return;
    if (res['status'] == 'Success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Attendance updated'),
          backgroundColor: const Color(0xFF4318FF),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Revert if failed
      setState(() {
        _attendanceList[index]['status'] = currentStatus;
      });
    }
  }

  Future<void> _logout() async {
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
    final totalCount = _attendanceList.length;
    final presentCount = _attendanceList
        .where((s) => s['status'] == 'Present')
        .length;
    final absentCount = totalCount - presentCount;

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
                      Icon(Icons.school_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Teacher Portal',
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
                    'ASSIGNED COURSES',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoadingCourses
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : _courses.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(25.0),
                          child: Text(
                            'No courses assigned yet.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _courses.length,
                          itemBuilder: (context, index) {
                            final course = _courses[index];
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
                                leading: const Icon(
                                  Icons.book_rounded,
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
                                  _loadCourseSessionsAndAttendance(course);
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
                            child: Text(
                              widget.username,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
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
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header & Session Date Dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedCourse != null
                                ? 'Course: $_selectedCourse'
                                : 'Teacher Dashboard',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2B3674),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'View class attendance and toggle manual status',
                            style: TextStyle(
                              color: Color(0xFFA3AED0),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (_sessions.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDate,
                              icon: const Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: Color(0xFF4318FF),
                              ),
                              items: _sessions.map((dateStr) {
                                return DropdownMenuItem<String>(
                                  value: dateStr,
                                  child: Text(
                                    'Session: $dateStr  ',
                                    style: const TextStyle(
                                      color: Color(0xFF2B3674),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) _onDateChanged(val);
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Summary Cards
                  Row(
                    children: [
                      _buildSummaryCard(
                        'Enrolled Students',
                        '$totalCount',
                        Icons.people_alt_rounded,
                        const Color(0xFF4318FF),
                      ),
                      const SizedBox(width: 20),
                      _buildSummaryCard(
                        'Present',
                        '$presentCount',
                        Icons.check_circle_rounded,
                        Colors.green,
                      ),
                      const SizedBox(width: 20),
                      _buildSummaryCard(
                        'Absent',
                        '$absentCount',
                        Icons.cancel_rounded,
                        Colors.redAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Students Attendance Table Card
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _isLoadingAttendance
                          ? const Center(child: CircularProgressIndicator())
                          : _attendanceList.isEmpty
                          ? const Center(
                              child: Text(
                                'No registered students found for this course.',
                                style: TextStyle(
                                  color: Color(0xFFA3AED0),
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _attendanceList.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = _attendanceList[index];
                                final isPresent = item['status'] == 'Present';
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: isPresent
                                        ? Colors.green.withValues(alpha: 0.12)
                                        : Colors.red.withValues(alpha: 0.12),
                                    child: Icon(
                                      isPresent ? Icons.check : Icons.close,
                                      color: isPresent
                                          ? Colors.green
                                          : Colors.redAccent,
                                    ),
                                  ),
                                  title: Text(
                                    item['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2B3674),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Roll No: ${item['roll_number']}',
                                    style: const TextStyle(
                                      color: Color(0xFFA3AED0),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPresent
                                              ? Colors.green.withValues(
                                                  alpha: 0.12,
                                                )
                                              : Colors.redAccent.withValues(
                                                  alpha: 0.12,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          item['status'],
                                          style: TextStyle(
                                            color: isPresent
                                                ? Colors.green
                                                : Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Switch(
                                        value: isPresent,
                                        activeThumbColor: Colors.green,
                                        onChanged: (_) => _toggleStatus(
                                          index,
                                          item['status'],
                                        ),
                                      ),
                                    ],
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

  Widget _buildSummaryCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
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
                  count,
                  style: const TextStyle(
                    fontSize: 24,
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
}
