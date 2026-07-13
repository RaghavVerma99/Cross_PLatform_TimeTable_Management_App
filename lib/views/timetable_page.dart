import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timetable_provider.dart';
import 'widgets/timetable_card.dart';
import 'widgets/add_slot_dialog.dart';

class TimetablePage extends ConsumerWidget {
  const TimetablePage({super.key});

  final List<String> _dayAbbr = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<String> _dayNames = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDay = ref.watch(timetableDayFilterProvider);
    final sortedSlots = ref.watch(filteredTimetableProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // OLED Black
      body: SafeArea(
        child: Column(
          children: [
            // Page Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Schedule',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        _dayNames[activeDay - 1].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A84FF), // Apple System Blue
                          letterSpacing: 1.5,
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
                      '${sortedSlots.length} Classes',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Day Selector Chips Row (iOS Calendar Style)
            _buildDaySelector(context, ref, activeDay),
            const SizedBox(height: 10),

            // Slots list
            Expanded(
              child: sortedSlots.isEmpty
                  ? _buildEmptyState(context, activeDay)
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: sortedSlots.length,
                      itemBuilder: (context, index) {
                        return TimetableCard(slot: sortedSlots[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSlotDialog(context),
        elevation: 3,
        backgroundColor: const Color(0xFF0A84FF), // Apple System Blue
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add_rounded,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDaySelector(BuildContext context, WidgetRef ref, int activeDay) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final dayNum = index + 1;
          final isSelected = dayNum == activeDay;
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () {
                  ref.read(timetableDayFilterProvider.notifier).state = dayNum;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF0A84FF) : const Color(0xFF1C1C1E), // Apple System Blue vs Gray 6
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0A84FF) : const Color(0xFF2C2C2E),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    _dayAbbr[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, int activeDay) {
    final dayName = _dayNames[activeDay - 1];
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1C1C1E), // Apple System Gray 6
                border: Border.all(color: const Color(0xFF2C2C2E), width: 0.8),
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 54,
                color: Color(0xFF0A84FF), // Apple System Blue
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No classes on $dayName',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enjoy your free day, or tap the button below to schedule a class!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showAddSlotDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddSlotDialog(),
    );
  }
}
