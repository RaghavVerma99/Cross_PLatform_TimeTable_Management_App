class TimetableSlot {
  final String id;
  final String subject;
  final String room;
  final String teacher;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String startTime; // "HH:mm" (24-hour format)
  final String endTime;   // "HH:mm" (24-hour format)
  final int colorValue;   // ARGB integer (e.g. 0xFFE94057)
  final String notes;

  TimetableSlot({
    required this.id,
    required this.subject,
    required this.room,
    required this.teacher,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.colorValue,
    this.notes = '',
  });

  // Convert to Map for Hive serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'room': room,
      'teacher': teacher,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'colorValue': colorValue,
      'notes': notes,
    };
  }

  // Create from Map for Hive deserialization
  factory TimetableSlot.fromMap(Map<dynamic, dynamic> map) {
    return TimetableSlot(
      id: map['id'] as String,
      subject: map['subject'] as String,
      room: map['room'] as String,
      teacher: map['teacher'] as String,
      dayOfWeek: map['dayOfWeek'] as int,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      colorValue: map['colorValue'] as int,
      notes: (map['notes'] ?? '') as String,
    );
  }

  // CopyWith helper
  TimetableSlot copyWith({
    String? id,
    String? subject,
    String? room,
    String? teacher,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    int? colorValue,
    String? notes,
  }) {
    return TimetableSlot(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      room: room ?? this.room,
      teacher: teacher ?? this.teacher,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      colorValue: colorValue ?? this.colorValue,
      notes: notes ?? this.notes,
    );
  }

  // Helper: converts "HH:mm" string to minutes from midnight
  int get startMinutes => _timeToMinutes(startTime);
  int get endMinutes => _timeToMinutes(endTime);

  static int _timeToMinutes(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        return hours * 60 + minutes;
      }
    } catch (_) {}
    return 0;
  }

  // Helper to format startTime and endTime into a 12-hour AM/PM string (e.g. "09:30 AM")
  String get formattedTimeRange {
    return '${_formatTo12Hour(startTime)} - ${_formatTo12Hour(endTime)}';
  }

  static String _formatTo12Hour(String time24) {
    try {
      final parts = time24.split(':');
      final hour24 = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final period = hour24 >= 12 ? 'PM' : 'AM';
      var hour12 = hour24 % 12;
      if (hour12 == 0) hour12 = 12;
      
      final minuteStr = minute < 10 ? '0$minute' : '$minute';
      return '$hour12:$minuteStr $period';
    } catch (_) {
      return time24;
    }
  }

  // Helper to determine if a slot is currently active at a given DateTime
  bool isActiveAt(DateTime dateTime) {
    if (dateTime.weekday != dayOfWeek) return false;
    final currentMinutes = dateTime.hour * 60 + dateTime.minute;
    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }
}
