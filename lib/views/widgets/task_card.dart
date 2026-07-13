import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = task.isCompleted;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isCompleted ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E), // Apple System Gray 6
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF2C2C2E), // Apple System Gray 5 border
            width: 0.8,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: GestureDetector(
            onTap: () {
              ref.read(taskProvider.notifier).toggleTask(task.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? const Color(0xFF0A84FF) : Colors.transparent, // Apple System Blue
                border: Border.all(
                  color: isCompleted ? const Color(0xFF0A84FF) : const Color(0xFF48484A), // iOS Dark Gray
                  width: 1.5,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          title: GestureDetector(
            onTap: () => _showEditDialog(context, ref),
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isCompleted ? const Color(0xFF8E8E93) : Colors.white,
                decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF453A), size: 20), // Apple System Red
            onPressed: () {
              ref.read(taskProvider.notifier).deleteTask(task.id);
            },
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E), // Apple System Gray 6
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF2C2C2E), width: 0.8),
        ),
        title: const Text(
          'Edit Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Task Title',
            hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
            filled: true,
            fillColor: const Color(0xFF2C2C2E), // Apple System Gray 5
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0A84FF), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                ref.read(taskProvider.notifier).updateTask(
                  task.copyWith(title: newTitle),
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save', style: TextStyle(color: Color(0xFF0A84FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
