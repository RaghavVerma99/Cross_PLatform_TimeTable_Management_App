import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timetable_provider.dart';
import 'widgets/day_selector.dart';
import 'widgets/class_card.dart';
import 'widgets/progress_header.dart';
import 'widgets/add_edit_class_sheet.dart';

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final allClasses = ref.watch(timetableProvider);

    // Filter classes for the selected day of the week
    final dayClasses = allClasses.where((c) => c.dayOfWeek == selectedDay).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            const ProgressHeader(),
            const DaySelector(),
            Expanded(
              child: dayClasses.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: dayClasses.length,
                      itemBuilder: (context, index) {
                        final item = dayClasses[index];
                        return ClassCard(item: item);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        elevation: 6,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFE94057),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating Neon Circle Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: const Color(0xFF2E2E2E), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A2387).withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: Color(0xFFE94057),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Classes Scheduled',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your schedule is clear for today! Add a new class to get started.',
              textAlign: Center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A8A8A),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAddSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Color(0xFF2E2E2E)),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Class', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            // Push it up slightly from absolute center
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEditClassSheet(),
    );
  }
}
