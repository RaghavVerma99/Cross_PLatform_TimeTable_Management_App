import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/timetable_slot.dart';
import '../../providers/timetable_provider.dart';

class AddSlotDialog extends ConsumerStatefulWidget {
  final TimetableSlot? slotToEdit;

  const AddSlotDialog({super.key, this.slotToEdit});

  @override
  ConsumerState<AddSlotDialog> createState() => _AddSlotDialogState();
}

class _AddSlotDialogState extends ConsumerState<AddSlotDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectController;
  late TextEditingController _roomController;
  late TextEditingController _teacherController;
  late TextEditingController _notesController;

  late int _selectedDay;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _selectedColor;

  // Curated premium colors matching our dark theme
  final List<int> _colorPresets = [
    0xFFE94057, // Crimson Pink
    0xFF8A2387, // Purple
    0xFFF27121, // Orange
    0xFF1AD2D9, // Teal/Cyan
    0xFF3B82F6, // Blue
    0xFF10B981, // Emerald Green
    0xFFF59E0B, // Amber/Yellow
  ];

  final List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.slotToEdit;

    _subjectController = TextEditingController(text: edit?.subject ?? '');
    _roomController = TextEditingController(text: edit?.room ?? '');
    _teacherController = TextEditingController(text: edit?.teacher ?? '');
    _notesController = TextEditingController(text: edit?.notes ?? '');

    _selectedDay = edit?.dayOfWeek ?? ref.read(timetableDayFilterProvider);
    
    // Parse times or default to current / next hour
    if (edit != null) {
      _startTime = _parseTimeString(edit.startTime);
      _endTime = _parseTimeString(edit.endTime);
      _selectedColor = edit.colorValue;
    } else {
      final now = DateTime.now();
      _startTime = TimeOfDay(hour: now.hour, minute: 0);
      _endTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
      _selectedColor = _colorPresets[0];
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _roomController.dispose();
    _teacherController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hourStr = time.hour.toString().padLeft(2, '0');
    final minuteStr = time.minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  String _formatTo12Hour(TimeOfDay time) {
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    var hour12 = time.hour % 12;
    if (hour12 == 0) hour12 = 12;
    final minuteStr = time.minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) => _buildTimePickerTheme(context, child),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        // Automatically set end time to start time + 1 hour if it's before or equal to start time
        if (_endTime.hour < _startTime.hour || 
           (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
          _endTime = TimeOfDay(hour: (_startTime.hour + 1) % 24, minute: _startTime.minute);
        }
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) => _buildTimePickerTheme(context, child),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Widget _buildTimePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        timePickerTheme: TimePickerThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          dialBackgroundColor: const Color(0xFF2C2C2C),
          dialHandColor: const Color(0xFFE94057),
          dialTextColor: Colors.white,
          entryModeIconColor: const Color(0xFFE94057),
          hourMinuteTextColor: Colors.white,
          hourMinuteColor: const Color(0xFF2C2C2C),
        ),
      ),
      child: child!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.slotToEdit != null;

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF2C2C2C), width: 1.5),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isEditing ? 'Edit Schedule Slot' : 'Add Schedule Slot',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white54),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject Input
              TextFormField(
                controller: _subjectController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Subject / Class Name', Icons.book_outlined),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter subject name' : null,
              ),
              const SizedBox(height: 16),

              // Room Input
              TextFormField(
                controller: _roomController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Room / Location (e.g. Room 302)', Icons.location_on_outlined),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter room or location' : null,
              ),
              const SizedBox(height: 16),

              // Teacher Input
              TextFormField(
                controller: _teacherController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Teacher / Professor', Icons.person_outline),
              ),
              const SizedBox(height: 16),

              // Day Select Dropdown
              DropdownButtonFormField<int>(
                initialValue: _selectedDay,
                dropdownColor: const Color(0xFF2C2C2C),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Day of Week', Icons.calendar_today_outlined),
                items: List.generate(7, (idx) {
                  return DropdownMenuItem(
                    value: idx + 1,
                    child: Text(_dayNames[idx]),
                  );
                }),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedDay = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Time Selectors
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartTime(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF3E3E3E)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Time',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTo12Hour(_startTime),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndTime(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF3E3E3E)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'End Time',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTo12Hour(_endTime),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Color Presets Select
              const Text(
                'Color Theme',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colorPresets.length,
                  itemBuilder: (context, index) {
                    final colorVal = _colorPresets[index];
                    final isSelected = _selectedColor == colorVal;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorVal),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(colorVal),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : Border.all(color: Colors.transparent),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Color(colorVal).withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ]
                              : [],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Notes Input
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Notes (Optional)', Icons.notes_outlined),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFFB0B0B0))),
        ),
        ElevatedButton(
          onPressed: _saveSlot,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(_selectedColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            isEditing ? 'Save Changes' : 'Add Class',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFE94057), size: 20),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE94057), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _saveSlot() {
    if (_formKey.currentState!.validate()) {
      final subject = _subjectController.text.trim();
      final room = _roomController.text.trim();
      final teacher = _teacherController.text.trim();
      final notes = _notesController.text.trim();

      final startTimeStr = _formatTimeOfDay(_startTime);
      final endTimeStr = _formatTimeOfDay(_endTime);

      final notifier = ref.read(timetableProvider.notifier);

      if (widget.slotToEdit != null) {
        final updated = widget.slotToEdit!.copyWith(
          subject: subject,
          room: room,
          teacher: teacher,
          dayOfWeek: _selectedDay,
          startTime: startTimeStr,
          endTime: endTimeStr,
          colorValue: _selectedColor,
          notes: notes,
        );
        notifier.updateSlot(updated);
      } else {
        final newSlot = TimetableSlot(
          id: const Uuid().v4(),
          subject: subject,
          room: room,
          teacher: teacher,
          dayOfWeek: _selectedDay,
          startTime: startTimeStr,
          endTime: endTimeStr,
          colorValue: _selectedColor,
          notes: notes,
        );
        notifier.addSlot(newSlot);
      }

      Navigator.of(context).pop();
    }
  }
}
