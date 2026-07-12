import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/timetable_provider.dart';
import '../models/timetable_slot.dart';
import '../models/task.dart';
import 'widgets/timetable_card.dart';
import 'widgets/task_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({Key? key}) : super(key: key);

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
      backgroundColor: const Color(0xFF121212),
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
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE94057), width: 1.5),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF1E1E1E),
                      child: Icon(Icons.person_rounded, color: Colors.white70),
                    ),
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
                  letterSpacing: 0.5,
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
                    letterSpacing: 0.5,
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
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (activeTasks.isNotEmpty)
                    Text(
                      '${activeTasks.length} left',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE94057),
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
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C2C2C), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Today\'s Classes', '$totalClassesToday', Icons.menu_book_rounded, const Color(0xFF1AD2D9)),
              _buildStatItem('Tasks Left', '$activeTasks', Icons.playlist_add_check_rounded, const Color(0xFFE94057)),
            ],
          ),
          if (totalTasks > 0) ...[
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF2C2C2C)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Task Completion',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${(taskProgress * 100).toInt()}%',
                  style: const TextStyle(color: Color(0xFFE94057), fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: taskProgress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white54,
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
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2C2C2C), width: 1.5),
        ),
        child: const Center(
          child: Text(
            'No class currently active 📚',
            style: TextStyle(
              color: Colors.white54,
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
        gradient: LinearGradient(
          colors: [themeColor, themeColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radio_button_checked_rounded, color: Colors.white, size: 12),
                    SizedBox(width: 6),
                    Text(
                      'ACTIVE NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                slot.room,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            slot.subject,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (slot.teacher.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'with ${slot.teacher}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                slot.formattedTimeRange,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C2C2C), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 45,
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${slot.formattedTimeRange} • ${slot.room}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
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
        ...previewTasks.map((task) => TaskCard(task: task)).toList(),
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
