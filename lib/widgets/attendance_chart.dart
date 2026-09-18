import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AttendanceChart extends StatefulWidget {
  const AttendanceChart({super.key});

  @override
  State<AttendanceChart> createState() => _AttendanceChartState();
}

class _AttendanceChartState extends State<AttendanceChart> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _weeklyStatsFuture;

  @override
  void initState() {
    super.initState();
    _weeklyStatsFuture = _apiService.getWeeklyStats();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Attendance Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B3674),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 220,
            child: FutureBuilder<List<dynamic>>(
              future: _weeklyStatsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No weekly data available'));
                }

                final weeklyData = snapshot.data!;
                
                // Maximum present value calculate karna chart scaling ke liye
                int maxCount = 1;
                for (var item in weeklyData) {
                  if ((item['count'] ?? 0) > maxCount) {
                    maxCount = item['count'];
                  }
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weeklyData.map<Widget>((item) {
                    final String day = item['day'] ?? '';
                    final int count = item['count'] ?? 0;
                    
                    final double barHeight = (count / maxCount) * 150;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$count',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4318FF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 28,
                          height: count == 0 ? 6 : barHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4318FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          day,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}