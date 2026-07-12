import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/timetable_slot.dart';

// Selected day filter provider (1 = Monday, 7 = Sunday)
// Defaults to current day of the week
final timetableDayFilterProvider = StateProvider<int>((ref) {
  final weekday = DateTime.now().weekday;
  return weekday;
});

// Main timetable list provider
final timetableProvider = StateNotifierProvider<TimetableNotifier, List<TimetableSlot>>((ref) {
  return TimetableNotifier();
});

// Sorted & filtered slots for the active day
final filteredTimetableProvider = Provider<List<TimetableSlot>>((ref) {
  final selectedDay = ref.watch(timetableDayFilterProvider);
  final slots = ref.watch(timetableProvider);

  // Filter slots for the selected day of the week
  final daySlots = slots.where((slot) => slot.dayOfWeek == selectedDay).toList();

  // Sort them chronologically by start time (using startMinutes helper)
  daySlots.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  
  return daySlots;
});

// Provider to get the current/active slot, if any, for the dashboard
final activeSlotProvider = Provider<TimetableSlot?>((ref) {
  final slots = ref.watch(timetableProvider);
  final now = DateTime.now();
  
  try {
    return slots.firstWhere((slot) => slot.isActiveAt(now));
  } catch (_) {
    return null;
  }
});

// Provider to get the upcoming slot for today (if any)
final upcomingSlotProvider = Provider<TimetableSlot?>((ref) {
  final slots = ref.watch(timetableProvider);
  final now = DateTime.now();
  final currentMinutes = now.hour * 60 + now.minute;
  
  // Filter for today's classes that haven't started yet
  final todayUpcoming = slots.where((slot) {
    return slot.dayOfWeek == now.weekday && slot.startMinutes > currentMinutes;
  }).toList();
  
  if (todayUpcoming.isEmpty) return null;
  
  // Sort and return the earliest upcoming class
  todayUpcoming.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  return todayUpcoming.first;
});

class TimetableNotifier extends StateNotifier<List<TimetableSlot>> {
  final Box _box = Hive.box('timetable');

  TimetableNotifier() : super([]) {
    _loadSlots();
  }

  void _loadSlots() {
    final List<TimetableSlot> loaded = [];
    for (var key in _box.keys) {
      final value = _box.get(key);
      if (value is Map) {
        loaded.add(TimetableSlot.fromMap(Map<dynamic, dynamic>.from(value)));
      }
    }
    state = loaded;
  }

  Future<void> addSlot(TimetableSlot slot) async {
    await _box.put(slot.id, slot.toMap());
    state = [...state, slot];
  }

  Future<void> updateSlot(TimetableSlot slot) async {
    await _box.put(slot.id, slot.toMap());
    state = [
      for (final s in state)
        if (s.id == slot.id) slot else s
    ];
  }

  Future<void> deleteSlot(String id) async {
    await _box.delete(id);
    state = state.where((s) => s.id != id).toList();
  }
}
