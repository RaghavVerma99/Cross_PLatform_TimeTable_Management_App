import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/timetable_class.dart';
import '../../providers/timetable_provider.dart';

class AddEditClassSheet extends ConsumerStatefulWidget {
  final TimetableClass? itemToEdit;

  const AddEditClassSheet({Key? key, this.itemToEdit}) : super(key: key);

  @override
  ConsumerState<AddEditClassSheet> createState() => _AddEditClassSheetState();
}

class _AddEditClassSheetState extends ConsumerState<AddEditClassSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _subjectController;
  late TextEditingController _teacherController;
  late TextEditingController _roomController;
  late TextEditingController _notesController;
  
  late int _selectedDay;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _selectedColorHex;

  final List<int> _presetColors = [
    0xFF00E5FF, // Cyan
    0xFFD500F9, // Magenta/Purple
    0xFFFFD600, // Amber/Yellow
    0xFF00E676, // Mint Green
    0xFFFF3D00, // Sunset Red
    0xFF2979FF, // Royal Blue
  ];

  final List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    
    _subjectController = TextEditingController(text: item?.subject ?? '');
    _teacherController = TextEditingController(text: item?.teacher ?? '');
    _roomController = TextEditingController(text: item?.room ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    
    // Default to the current day in provider or item day
    _selectedDay = item?.dayOfWeek ?? ref.read(selectedDayProvider);
    
    _startTime = item != null 
        ? item.startTimeOfDay 
        : const TimeOfDay(hour: 9, minute: 0);
        
    _endTime = item != null 
        ? item.endTimeOfDay 
        : const TimeOfDay(hour: 10, minute: 0);
        
    _selectedColorHex = item?.colorHex ?? _presetColors.first;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(_selectedColorHex),
              onPrimary: Colors.black,
              surface: const Color(0xFF2C2C2C),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          // Ensure end time is at least equal to start time by default
          final startMinutes = _startTime.hour * 60 + _startTime.minute;
          final endMinutes = _endTime.hour * 60 + _endTime.minute;
          if (endMinutes < startMinutes) {
            _endTime = TimeOfDay(
              hour: (_startTime.hour + 1) % 24,
              minute: _startTime.minute,
            );
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final String id = widget.itemToEdit?.id ?? const Uuid().v4();
    final bool isCompleted = widget.itemToEdit?.isCompleted ?? false;

    final newItem = TimetableClass(
      id: id,
      subject: _subjectController.text.trim(),
      teacher: _teacherController.text.trim(),
      room: _roomController.text.trim(),
      dayOfWeek: _selectedDay,
      startTime: _formatTimeOfDay(_startTime),
      endTime: _formatTimeOfDay(_endTime),
      colorHex: _selectedColorHex,
      notes: _notesController.text.trim(),
      isCompleted: isCompleted,
    );

    final notifier = ref.read(timetableProvider.notifier);
    if (widget.itemToEdit == null) {
      notifier.addClass(newItem);
    } else {
      notifier.updateClass(newItem);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.itemToEdit != null;
    final primaryThemeColor = Color(_selectedColorHex);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(color: Color(0xFF2C2C2C), width: 1.5),
        ),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet drag handle / Header
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF444444),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEditMode ? 'Edit Class Schedule' : 'Add Class Schedule',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              
              // Subject Input
              TextFormField(
                controller: _subjectController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Subject Name',
                  labelStyle: const TextStyle(color: Color(0xFF8E8E8E)),
                  prefixIcon: const Icon(Icons.book_outlined, color: Color(0xFF8E8E8E)),
                  filled: true,
                  fillColor: const Color(0xFF121212),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryThemeColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Teacher & Room in a Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _teacherController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Teacher / Professor',
                        labelStyle: const TextStyle(color: Color(0xFF8E8E8E)),
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF8E8E8E)),
                        filled: true,
                        fillColor: const Color(0xFF121212),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primaryThemeColor, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _roomController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Room / Lab',
                        labelStyle: const TextStyle(color: Color(0xFF8E8E8E)),
                        prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF8E8E8E)),
                        filled: true,
                        fillColor: const Color(0xFF121212),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primaryThemeColor, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Day of the Week Dropdown
              DropdownButtonFormField<int>(
                value: _selectedDay,
                dropdownColor: const Color(0xFF2C2C2C),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Day of the Week',
                  labelStyle: const TextStyle(color: Color(0xFF8E8E8E)),
                  prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF8E8E8E)),
                  filled: true,
                  fillColor: const Color(0xFF121212),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryThemeColor, width: 1.5),
                  ),
                ),
                items: List.generate(7, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text(_dayNames[index]),
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
              const SizedBox(height: 16),

              // Start Time & End Time buttons
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, true),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2E2E2E)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: Color(0xFF8E8E8E)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Starts At', style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(
                                  _startTime.format(context),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, false),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2E2E2E)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: Color(0xFF8E8E8E)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Ends At', style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(
                                  _endTime.format(context),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Color Preset Selector
              const Text(
                'Card Highlight Color',
                style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presetColors.length,
                  itemBuilder: (context, index) {
                    final colorHex = _presetColors[index];
                    final color = Color(colorHex);
                    final isColorSelected = _selectedColorHex == colorHex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorHex = colorHex;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isColorSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : Border.all(color: Colors.transparent, width: 0),
                          boxShadow: isColorSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.6),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
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
                decoration: InputDecoration(
                  labelText: 'Notes / Todo Items (Optional)',
                  labelStyle: const TextStyle(color: Color(0xFF8E8E8E)),
                  prefixIcon: const Icon(Icons.sticky_note_2_outlined, color: Color(0xFF8E8E8E)),
                  filled: true,
                  fillColor: const Color(0xFF121212),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryThemeColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryThemeColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: primaryThemeColor.withOpacity(0.5),
                      ),
                      onPressed: _saveForm,
                      child: Text(
                        isEditMode ? 'Update Class' : 'Create Class',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
