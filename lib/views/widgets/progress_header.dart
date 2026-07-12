import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/timetable_provider.dart';

class ProgressHeader extends ConsumerWidget {
  const ProgressHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final allClasses = ref.watch(timetableProvider);

    // Filter classes for selected day
    final dayClasses = allClasses.where((c) => c.dayOfWeek == selectedDay).toList();
    final totalClasses = dayClasses.length;
    final completedClasses = dayClasses.where((c) => c.isCompleted).length;

    // Calculate progress ratio
    final double progress = totalClasses == 0 ? 0.0 : completedClasses / totalClasses;

    // Current date format
    final String formattedDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    // Generate motivational message
    String titleText;
    String subText;
    if (totalClasses == 0) {
      titleText = 'No classes today!';
      subText = 'Enjoy your free time, rest, and recharge. ☕';
    } else if (completedClasses == 0) {
      titleText = 'Ready to start?';
      subText = 'You have $totalClasses schedule${totalClasses > 1 ? 's' : 'd'} today. Let\'s do this! 🚀';
    } else if (completedClasses == totalClasses) {
      titleText = 'All caught up!';
      subText = 'You have completed all $totalClasses classes. Great work! 🎉';
    } else {
      titleText = 'Keep pushing!';
      subText = 'Completed $completedClasses of $totalClasses classes today. 💪';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Title & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chronos',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'TIMETABLE PLANNER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF27121),
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2E2E2E)),
                ),
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD0D0D0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF1E1E1E).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2C2C2C), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      titleText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (totalClasses > 0)
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE94057),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
                if (totalClasses > 0) ...[
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        height: 8,
                        width: (MediaQuery.of(context).size.width - 82) * progress,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE94057).withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
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
