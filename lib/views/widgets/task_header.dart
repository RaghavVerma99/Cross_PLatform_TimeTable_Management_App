import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';

class TaskHeader extends ConsumerWidget {
  const TaskHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final progress = total == 0 ? 0.0 : completed / total;
    
    final dateStr = DateFormat('EEEE, MMM d').format(DateTime.now());

    String statsText;
    if (total == 0) {
      statsText = 'Create a task to get started! 🎯';
    } else if (completed == total) {
      statsText = 'Outstanding! All tasks completed. 🎉';
    } else {
      statsText = '$completed of $total tasks completed today. 💪';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App bar replacement
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tasks',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E), // Apple System Gray 6
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2C2C2E), width: 0.8),
                ),
                child: Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFEBEBF5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E), // Apple System Gray 6
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2C2C2E), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daily Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (total > 0)
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5E5CE6), // Apple System Indigo
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  statsText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                if (total > 0) ...[
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E), // Apple System Gray 5
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        height: 6,
                        width: (MediaQuery.of(context).size.width - 82) * progress,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5E5CE6), // Apple System Indigo
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5E5CE6).withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
