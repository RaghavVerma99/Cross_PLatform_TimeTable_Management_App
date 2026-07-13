import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/timetable_slot.dart';
import '../../providers/timetable_provider.dart';
import 'add_slot_dialog.dart';

class TimetableCard extends ConsumerWidget {
  final TimetableSlot slot;

  const TimetableCard({super.key, required this.slot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isActive = slot.isActiveAt(now);
    final themeColor = Color(slot.colorValue);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // Apple System Gray 6
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? themeColor : const Color(0xFF2C2C2E), // Subtle subject color for active border
          width: isActive ? 1.0 : 0.8,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Color side-indicator bar
              Container(
                width: 5,
                color: themeColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time and Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 14, color: themeColor),
                              const SizedBox(width: 6),
                              Text(
                                slot.formattedTimeRange,
                                style: TextStyle(
                                  color: themeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF30D158).withValues(alpha: 0.15), // Apple Green tint
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
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Subject Title
                      Text(
                        slot.subject,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Room and Teacher Row
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF8E8E93)),
                          const SizedBox(width: 4),
                          Text(
                            slot.room,
                            style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                          ),
                          if (slot.teacher.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            const Icon(Icons.person_outline, size: 14, color: Color(0xFF8E8E93)),
                            const SizedBox(width: 4),
                            Text(
                              slot.teacher,
                              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                            ),
                          ],
                        ],
                      ),

                      // Optional notes
                      if (slot.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          slot.notes,
                          style: const TextStyle(
                            color: Colors.white30,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Actions on the trailing side
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white30, size: 18),
                    onPressed: () => _editSlot(context),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF453A), size: 18), // Apple Red
                    onPressed: () => _deleteSlot(context, ref),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  void _editSlot(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddSlotDialog(slotToEdit: slot),
    );
  }

  void _deleteSlot(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E), // Apple System Gray 6
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF2C2C2E), width: 0.8),
        ),
        title: const Text('Delete Class?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Are you sure you want to remove "${slot.subject}" from your timetable?', style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () {
              ref.read(timetableProvider.notifier).deleteSlot(slot.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF453A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
