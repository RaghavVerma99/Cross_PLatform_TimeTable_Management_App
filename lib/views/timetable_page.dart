import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timetable_provider.dart';
import 'widgets/timetable_card.dart';
import 'widgets/add_slot_dialog.dart';

class TimetablePage extends ConsumerWidget {
  const TimetablePage({Key? key}) : super(key: key);

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
      backgroundColor: const Color(0xFF121212),
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
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _dayNames[activeDay - 1].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE94057),
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
                      border: Border.all(color: const Color(0xFF2C2C2C)),
                    ),
                    child: Text(
                      '${sortedSlots.length} Classes',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD0D0D0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Day Selector Chips Row
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

  Widget _buildDaySelector(BuildContext context, WidgetRef ref, int activeDay) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final dayNum = index + 1;
          final isSelected = dayNum == activeDay;
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  ref.read(timetableDayFilterProvider.notifier).state = dayNum;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : const Color(0xFF1E1E1E),
                    border: isSelected
                        ? null
                        : Border.all(color: const Color(0xFF2C2C2C), width: 1.5),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFE94057).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _dayAbbr[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF8E8E8E),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
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
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: const Color(0xFF2C2C2C), width: 2),
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 54,
                color: Color(0xFFE94057),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No classes on $dayName',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enjoy your free time, or tap the button below to schedule a class!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF8A8A8A),
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
