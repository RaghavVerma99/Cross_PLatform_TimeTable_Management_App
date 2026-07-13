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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? themeColor : const Color(0xFF2C2C2C),
          width: isActive ? 2.0 : 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Color side-indicator bar
              Container(
                width: 6,
                color: themeColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
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
                                ),
                              ),
                            ],
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: themeColor,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'LIVE NOW',
                                    style: TextStyle(
                                      color: themeColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
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
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Room and Teacher Row
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: Colors.white60),
                          const SizedBox(width: 4),
                          Text(
                            slot.room,
                            style: const TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                          if (slot.teacher.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            Icon(Icons.person_outline, size: 16, color: Colors.white60),
                            const SizedBox(width: 4),
                            Text(
                              slot.teacher,
                              style: const TextStyle(color: Colors.white60, fontSize: 13),
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
                            color: Colors.white38,
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
                    icon: const Icon(Icons.edit_outlined, color: Colors.white38, size: 20),
                    onPressed: () => _editSlot(context),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
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
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Class?', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to remove "${slot.subject}" from your timetable?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              ref.read(timetableProvider.notifier).deleteSlot(slot.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
