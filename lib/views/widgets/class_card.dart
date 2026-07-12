import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/timetable_class.dart';
import '../../providers/timetable_provider.dart';
import 'add_edit_class_sheet.dart';

class ClassCard extends ConsumerWidget {
  final TimetableClass item;

  const ClassCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardColor = item.color;
    final isCompleted = item.isCompleted;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isCompleted ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFF1E1E1E),
        elevation: isCompleted ? 0 : 4,
        shadowColor: cardColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isCompleted
                ? const Color(0xFF2E2E2E)
                : cardColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Colored left accent bar
                Container(
                  width: 6,
                  color: isCompleted ? const Color(0xFF4E4E4E) : cardColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Completion check
                            GestureDetector(
                              onTap: () {
                                ref.read(timetableProvider.notifier).toggleCompletion(item.id);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCompleted ? cardColor : Colors.transparent,
                                  border: Border.all(
                                    color: isCompleted ? cardColor : const Color(0xFF7E7E7E),
                                    width: 2,
                                  ),
                                ),
                                child: isCompleted
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Subject Title
                            Expanded(
                              child: Text(
                                item.subject,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                            // Actions Menu
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Color(0xFFB0B0B0)),
                              color: const Color(0xFF2C2C2C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditSheet(context);
                                } else if (value == 'delete') {
                                  _confirmDelete(context, ref);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                                      SizedBox(width: 10),
                                      Text('Edit', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                      SizedBox(width: 10),
                                      Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Time range
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF8A8A8A)),
                            const SizedBox(width: 6),
                            Text(
                              '${item.formatTime(context, item.startTime)} - ${item.formatTime(context, item.endTime)}',
                              style: const TextStyle(
                                color: Color(0xFFD0D0D0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Teacher and Room
                        Row(
                          children: [
                            // Teacher
                            if (item.teacher.isNotEmpty) ...[
                              const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF8A8A8A)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.teacher,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Color(0xFFB0B0B0)),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            // Room
                            if (item.room.isNotEmpty) ...[
                              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF8A8A8A)),
                              const SizedBox(width: 6),
                              Text(
                                item.room,
                                style: const TextStyle(
                                  color: Color(0xFFB0B0B0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Notes (if any)
                        if (item.notes.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161616),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              item.notes,
                              style: const TextStyle(
                                color: Color(0xFF8E8E8E),
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditClassSheet(itemToEdit: item),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Delete Class', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${item.subject}"?',
          style: const TextStyle(color: Color(0xFFD0D0D0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFB0B0B0))),
          ),
          TextButton(
            onPressed: () {
              ref.read(timetableProvider.notifier).deleteClass(item.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
