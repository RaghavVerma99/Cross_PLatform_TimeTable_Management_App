import 'package:flutter/material.dart';

class TimetableClass {
  final String id;
  final String subject;
  final String teacher;
  final String room;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String startTime; // Format: "HH:mm" (24h)
  final String endTime; // Format: "HH:mm" (24h)
  final int colorHex; // Hex value of the theme color
  final String notes;
  final bool isCompleted;

  TimetableClass({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.colorHex,
    this.notes = '',
    this.isCompleted = false,
  });

  // Convert to Map for Hive serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'teacher': teacher,
      'room': room,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'colorHex': colorHex,
      'notes': notes,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Create from Map for Hive deserialization
  factory TimetableClass.fromMap(Map<dynamic, dynamic> map) {
    return TimetableClass(
      id: map['id'] as String,
      subject: map['subject'] as String,
      teacher: map['teacher'] as String,
      room: map['room'] as String,
      dayOfWeek: map['dayOfWeek'] as int,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      colorHex: map['colorHex'] as int,
      notes: (map['notes'] ?? '') as String,
      isCompleted: (map['isCompleted'] ?? 0) == 1,
    );
  }

  // CopyWith helper for updating states
  TimetableClass copyWith({
    String? id,
    String? subject,
    String? teacher,
    String? room,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    int? colorHex,
    String? notes,
    bool? isCompleted,
  }) {
    return TimetableClass(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      room: room ?? this.room,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      colorHex: colorHex ?? this.colorHex,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Get start TimeOfDay
  TimeOfDay get startTimeOfDay {
    final parts = startTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Get end TimeOfDay
  TimeOfDay get endTimeOfDay {
    final parts = endTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Formatted String for UI display (e.g. 09:30 AM)
  String formatTime(BuildContext context, String timeStr) {
    final parts = timeStr.split(':');
    final tod = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    return tod.format(context);
  }

  String get formattedStartTimeFormatted => startTime; // fallback
  
  // Quick getter for color
  Color get color => Color(colorHex);
}
