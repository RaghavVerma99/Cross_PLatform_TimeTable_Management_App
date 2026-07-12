import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

enum TaskFilter { all, active, completed }

// Filter selection state provider
final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

// Main tasks list provider
final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

// Reactive provider that returns tasks filtered by the current selection
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final tasks = ref.watch(taskProvider);

  switch (filter) {
    case TaskFilter.active:
      return tasks.where((task) => !task.isCompleted).toList();
    case TaskFilter.completed:
      return tasks.where((task) => task.isCompleted).toList();
    case TaskFilter.all:
    default:
      return tasks;
  }
});

class TaskNotifier extends StateNotifier<List<Task>> {
  late final Box _box;

  TaskNotifier() : super([]) {
    _box = Hive.box('tasks');
    _loadTasks();
  }

  void _loadTasks() {
    final List<Task> loaded = [];
    for (var key in _box.keys) {
      final map = _box.get(key);
      if (map is Map) {
        loaded.add(Task.fromMap(map));
      }
    }
    state = loaded;
  }

  Future<void> addTask(Task task) async {
    await _box.put(task.id, task.toMap());
    state = [...state, task];
  }

  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task.toMap());
    state = [
      for (final t in state)
        if (t.id == task.id) task else t
    ];
  }

  Future<void> toggleTask(String id) async {
    final index = state.indexWhere((t) => t.id == id);
    if (index != -1) {
      final updated = state[index].copyWith(isCompleted: !state[index].isCompleted);
      await updateTask(updated);
    }
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
    state = state.where((t) => t.id != id).toList();
  }
}
