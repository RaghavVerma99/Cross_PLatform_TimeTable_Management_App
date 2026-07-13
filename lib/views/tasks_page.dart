import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'widgets/task_header.dart';
import 'widgets/task_card.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTasks = ref.watch(filteredTasksProvider);
    final activeFilter = ref.watch(taskFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // OLED Black
      body: SafeArea(
        child: Column(
          children: [
            const TaskHeader(),
            _buildFilterRow(context, ref, activeFilter),
            Expanded(
              child: filteredTasks.isEmpty
                  ? _buildEmptyState(context, activeFilter)
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        return TaskCard(task: filteredTasks[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
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

  Widget _buildFilterRow(BuildContext context, WidgetRef ref, TaskFilter activeFilter) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // Apple System Gray 6
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: TaskFilter.values.map((filter) {
          final isSelected = filter == activeFilter;
          String label;
          switch (filter) {
            case TaskFilter.active:
              label = 'Active';
              break;
            case TaskFilter.completed:
              label = 'Completed';
              break;
            case TaskFilter.all:
            default:
              label = 'All';
              break;
          }

          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(taskFilterProvider.notifier).state = filter;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2C2C2E) : Colors.transparent, // Apple System Gray 5
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF8E8E93), // iOS System Gray
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TaskFilter filter) {
    String message;
    IconData icon;
    switch (filter) {
      case TaskFilter.active:
        message = 'No active tasks. Time to relax! ☕';
        icon = Icons.done_all_rounded;
        break;
      case TaskFilter.completed:
        message = 'No completed tasks yet. Keep moving! 🚀';
        icon = Icons.hourglass_empty_rounded;
        break;
      case TaskFilter.all:
      default:
        message = 'Your todo list is empty. Add a task!';
        icon = Icons.assignment_turned_in_outlined;
        break;
    }

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
              child: Icon(
                icon,
                size: 54,
                color: const Color(0xFF0A84FF), // Apple System Blue
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E), // Apple System Gray 6
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF2C2C2E), width: 0.8),
        ),
        title: const Text(
          'Add Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'What needs to be done?',
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
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                ref.read(taskProvider.notifier).addTask(
                  Task(
                    id: const Uuid().v4(),
                    title: title,
                  ),
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add', style: TextStyle(color: Color(0xFF0A84FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
