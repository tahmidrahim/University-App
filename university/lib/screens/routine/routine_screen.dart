import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  Map<String, List<dynamic>> weeklySchedule = {};
  int selectedDayIndex = 0;
  int todayIndex = 0;
  bool isLoading = true;
  String errorMessage = '';

  final List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  final List<String> fullDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  late List<String> dates;
  late List<DateTime> fullDates;

  @override
  void initState() {
    super.initState();
    _calculateWeekDates();
    _setCurrentDayAutomatically();
    loadData();
  }

  void _calculateWeekDates() {
    final now = DateTime.now();
    // Get Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));

    fullDates = [];
    dates = [];

    for (int i = 0; i < 6; i++) {
      final date = monday.add(Duration(days: i));
      fullDates.add(date);
      dates.add('${date.day}');
    }
  }

  void _setCurrentDayAutomatically() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find which day matches today's date
    todayIndex = 0;
    for (int i = 0; i < fullDates.length; i++) {
      final date = DateTime(
        fullDates[i].year,
        fullDates[i].month,
        fullDates[i].day,
      );
      if (date == today) {
        todayIndex = i;
        break;
      }
    }

    // Automatically select today's day
    selectedDayIndex = todayIndex;
  }

  Future<void> loadData() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/data/routine.json',
      );
      final data = json.decode(response);
      setState(() {
        weeklySchedule = Map<String, List<dynamic>>.from(
          data['weekly_schedule'],
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Ensure routine.json is in lib/data/";
        isLoading = false;
      });
    }
  }

  bool _isClassNow(String timeRange) {
    try {
      final parts = timeRange.split(' - ');
      final now = DateTime.now();
      final format = DateFormat("hh:mm a");
      final start = format.parse(parts[0]);
      final end = format.parse(parts[1]);
      final currentTime = format.parse(format.format(now));
      return currentTime.isAfter(start) && currentTime.isBefore(end);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentClasses = weeklySchedule[fullDays[selectedDayIndex]] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Class Routine",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeader(),
                  _buildDaySelector(),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: currentClasses.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _buildModernClassCard(currentClasses[index]),
                              childCount: currentClasses.length,
                            ),
                          ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weekly Schedule",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            _buildSemesterBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: const Text(
        "Spring 2026",
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 110,
        maxHeight: 110,
        child: Container(
          color: const Color(0xFFF8FAFC),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            itemBuilder: (context, index) {
              final isSelected = selectedDayIndex == index;
              final isToday = todayIndex == index;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    selectedDayIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade700 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: isToday && !isSelected
                        ? Border.all(color: Colors.blue.shade300, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? Colors.blue.withOpacity(0.3)
                            : Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        days[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isToday
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade500),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dates[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isToday
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade800),
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      if (isToday)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Today",
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModernClassCard(Map<String, dynamic> item) {
    bool isLive = _isClassNow(item['time'] ?? "");

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isLive
            ? Border.all(color: Colors.blue.shade300, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isLive
                ? Colors.blue.withOpacity(0.1)
                : Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['course_code'] ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              if (isLive) _buildLiveBadge(),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time,
            item['time'] ?? "",
            isLive ? Colors.blue : null,
          ),
          const SizedBox(height: 4),
          _buildInfoRow(Icons.person_outline, item['teacher'] ?? "", null),
          const SizedBox(height: 4),
          _buildInfoRow(
            Icons.room_outlined,
            "Room: ${item['room'] ?? 'TBA'}",
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        "LIVE",
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color? color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color ?? Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Icon(Icons.weekend_outlined, size: 80, color: Colors.grey.shade200),
        const SizedBox(height: 16),
        Text(
          "No classes today!",
          style: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Enjoy your free time",
          style: TextStyle(color: Colors.grey.shade300),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        child != oldDelegate.child;
  }
}
