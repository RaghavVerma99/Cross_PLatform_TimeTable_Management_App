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
      backgroundColor: const Color(0xFF121212),
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

  Widget _buildFilterRow(BuildContext context, WidgetRef ref, TaskFilter activeFilter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                onTap: () {
                  ref.read(taskFilterProvider.notifier).state = filter;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : const Color(0xFF1E1E1E),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFE94057).withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                    border: isSelected
                        ? null
                        : Border.all(color: const Color(0xFF2E2E2E), width: 1.5),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFFB0B0B0),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
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
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: const Color(0xFF2E2E2E), width: 2),
              ),
              child: Icon(
                icon,
                size: 54,
                color: const Color(0xFFE94057),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF8A8A8A),
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
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Add Task', style: TextStyle(color: Colors.white)),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'What needs to be done?',
            hintStyle: TextStyle(color: Color(0xFF8E8E8E)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4E4E4E)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE94057)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFB0B0B0))),
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
            child: const Text('Add', style: TextStyle(color: Color(0xFFE94057))),
          ),
        ],
      ),
    );
  }
}
