import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/timetable_provider.dart';
import '../models/timetable_slot.dart';
import '../models/task.dart';
import 'widgets/task_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning 🌅';
    } else if (hour < 17) {
      return 'Good Afternoon ☀️';
    } else {
      return 'Good Evening 🌌';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSlot = ref.watch(activeSlotProvider);
    final upcomingSlot = ref.watch(upcomingSlotProvider);
    final tasks = ref.watch(taskProvider);
    final timetableSlots = ref.watch(timetableProvider);

    final today = DateTime.now();
    final todaySlots = timetableSlots.where((slot) => slot.dayOfWeek == today.weekday).toList();
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final activeTasks = tasks.where((t) => !t.isCompleted).toList();

    final dateStr = DateFormat('EEEE, MMMM d').format(today);

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // OLED Black
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93), // iOS System Gray
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFF1C1C1E), // Apple System Gray 6
                    child: Icon(Icons.person_rounded, color: Color(0xFF8E8E93), size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Overview Stats Card
              _buildOverviewCard(todaySlots.length, activeTasks.length, completedTasks, tasks.length),
              const SizedBox(height: 24),

              // "Happening Now" Section
              const Text(
                'Happening Now',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 12),
              _buildHappeningNow(context, activeSlot),
              const SizedBox(height: 24),

              // "Up Next" Section
              if (upcomingSlot != null) ...[
                const Text(
                  'Up Next Today',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),
                _buildUpcomingCard(context, upcomingSlot),
                const SizedBox(height: 24),
              ],

              // Today's Pending Tasks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pending Tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (activeTasks.isNotEmpty)
                    Text(
                      '${activeTasks.length} left',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0A84FF), // Apple System Blue
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTasksPreview(context, activeTasks),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(int totalClassesToday, int activeTasks, int completedTasks, int totalTasks) {
    final taskProgress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // Apple System Gray 6
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 0.8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Summary',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatItem('Classes Today', '$totalClassesToday', Icons.calendar_today_rounded, const Color(0xFFFF9F0A)), // Apple Orange
                const SizedBox(height: 12),
                _buildStatItem('Pending Tasks', '$activeTasks', Icons.checklist_rounded, const Color(0xFF0A84FF)), // Apple Blue
              ],
            ),
          ),
          if (totalTasks > 0) ...[
            const SizedBox(width: 16),
            SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 7,
                      color: const Color(0xFF2C2C2E), // Apple System Gray 5
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: taskProgress,
                      strokeWidth: 7,
                      color: const Color(0xFF5E5CE6), // Apple System Indigo
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(taskProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Text(
                        'DONE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String count, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHappeningNow(BuildContext context, TimetableSlot? slot) {
    if (slot == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2C2C2E), width: 0.8),
        ),
        child: const Center(
          child: Text(
            'No classes right now',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final themeColor = Color(slot.colorValue);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 1.0),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF30D158).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF30D158),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE NOW',
                      style: TextStyle(
                        color: Color(0xFF30D158),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                slot.room,
                style: TextStyle(
                  color: themeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            slot.subject,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          if (slot.teacher.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              slot.teacher,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: themeColor, size: 14),
              const SizedBox(width: 6),
              Text(
                slot.formattedTimeRange,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, TimetableSlot slot) {
    final themeColor = Color(slot.colorValue);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.subject,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${slot.formattedTimeRange} • ${slot.room}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              slot.startTime,
              style: TextStyle(
                color: themeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksPreview(BuildContext context, List<Task> activeTasks) {
    if (activeTasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2C2C2C), width: 1.5),
        ),
        child: const Center(
          child: Text(
            'All caught up on tasks! 🎉',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Limit preview to 3 tasks
    final previewTasks = activeTasks.take(3).toList();

    return Column(
      children: [
        ...previewTasks.map((task) => TaskCard(task: task)),
        if (activeTasks.length > 3) ...[
          const SizedBox(height: 6),
          Center(
            child: Text(
              '+ ${activeTasks.length - 3} more tasks in Tasks Tab',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white30,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
