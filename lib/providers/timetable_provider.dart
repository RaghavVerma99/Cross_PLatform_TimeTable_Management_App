import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/timetable_class.dart';

// Provider for the list of timetable classes
final timetableProvider = StateNotifierProvider<TimetableNotifier, List<TimetableClass>>((ref) {
  return TimetableNotifier();
});

// Provider for the currently active day of the week (1 = Mon, 7 = Sun)
final selectedDayProvider = StateProvider<int>((ref) {
  return DateTime.now().weekday;
});

class TimetableNotifier extends StateNotifier<List<TimetableClass>> {
  late final Box _box;

  TimetableNotifier() : super([]) {
    _box = Hive.box('timetable_classes');
    _loadClasses();
  }

  // Load classes from the Hive box
  void _loadClasses() {
    final List<TimetableClass> loaded = [];
    for (var key in _box.keys) {
      final map = _box.get(key);
      if (map is Map) {
        loaded.add(TimetableClass.fromMap(map));
      }
    }
    _sortAndSetState(loaded);
  }

  // Helper to sort classes chronologically and update state
  void _sortAndSetState(List<TimetableClass> list) {
    list.sort((a, b) {
      final aParts = a.startTime.split(':');
      final bParts = b.startTime.split(':');
      final aMinutes = int.parse(aParts[0]) * 60 + int.parse(aParts[1]);
      final bMinutes = int.parse(bParts[0]) * 60 + int.parse(bParts[1]);
      return aMinutes.compareTo(bMinutes);
    });
    state = list;
  }

  // Add a new class/event
  Future<void> addClass(TimetableClass item) async {
    await _box.put(item.id, item.toMap());
    _sortAndSetState([...state, item]);
  }

  // Update an existing class/event
  Future<void> updateClass(TimetableClass item) async {
    await _box.put(item.id, item.toMap());
    state = [
      for (final c in state)
        if (c.id == item.id) item else c
    ];
    _sortAndSetState(state);
  }

  // Delete a class/event
  Future<void> deleteClass(String id) async {
    await _box.delete(id);
    state = state.where((c) => c.id != id).toList();
  }

  // Toggle completed state
  Future<void> toggleCompletion(String id) async {
    final index = state.indexWhere((c) => c.id == id);
    if (index != -1) {
      final item = state[index];
      final updated = item.copyWith(isCompleted: !item.isCompleted);
      await updateClass(updated);
    }
  }
}
