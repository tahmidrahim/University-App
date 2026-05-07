import 'package:flutter/material.dart';
import 'package:university/models/routine_model.dart';
import 'package:university/models/assignment_model.dart';
import 'package:university/services/routine_service.dart';
import 'package:university/services/assignment_service.dart';
import 'package:university/screens/scanner/scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Type-safe state variables
  StudentRoutine? routineData;
  List<Course> todayClasses = [];
  List<Assignment> pendingAssignments = [];

  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final routineService = RoutineService();
      final assignmentService = AssignmentService();

      final fullRoutine = await routineService.getRoutine();
      final dayName = _getDayName(DateTime.now().weekday);
      final classes = await routineService.getClassesForDay(dayName);
      final pending = await assignmentService.getPendingAssignments();

      if (!mounted) return;
      setState(() {
        routineData = fullRoutine;
        todayClasses = classes;
        pendingAssignments = pending;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  String _getDayName(int weekday) {
    const days = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return days[weekday] ?? 'Monday';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScannerScreen()),
          ),
          backgroundColor: Colors.blue.shade700,
          elevation: 4,
          child: const Icon(
            Icons.qr_code_scanner,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              displacement: 100,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildWelcomeCard(),
                        const SizedBox(height: 32),
                        _buildSectionHeader(
                          "Today's Schedule",
                          Icons.calendar_today_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildClassList(),
                        const SizedBox(height: 32),
                        _buildSectionHeader(
                          "Pending Tasks",
                          Icons.assignment_late_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildAssignmentList(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      backgroundColor: Colors.blue.shade700,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        background: Container(color: Colors.blue.shade700),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: loadData,
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.person_rounded,
              size: 35,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routineData?.program.split(' ').first ?? 'Student',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Section ${routineData?.section ?? ''} • ${routineData?.semester ?? ''}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildClassList() {
    if (todayClasses.isEmpty) {
      return _buildEmptyState("No classes scheduled today.");
    }
    return Column(
      children: todayClasses.map((item) => _buildClassCard(item)).toList(),
    );
  }

  Widget _buildAssignmentList() {
    if (pendingAssignments.isEmpty) {
      return _buildEmptyState("You're all caught up!");
    }
    return Column(
      children: pendingAssignments
          .map((item) => _buildAssignmentCard(item))
          .toList(),
    );
  }

  Widget _buildClassCard(Course item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.book_rounded,
              color: Colors.blue.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.courseCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  item.time,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Color(0xFFCBD5E1),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Assignment item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: item.isOverdue
              ? Colors.red.withOpacity(0.3)
              : Colors.orange.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            item.isOverdue ? Icons.warning_amber_rounded : Icons.circle,
            color: item.isOverdue ? Colors.red : Colors.orange,
            size: 10,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  item.subject,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.dueDate,
                style: TextStyle(
                  color: item.isOverdue
                      ? Colors.red.shade400
                      : Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (item.isOverdue)
                Text(
                  'Overdue',
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
