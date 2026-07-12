import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'views/timetable_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local Hive database
  await Hive.initFlutter();
  await Hive.openBox('timetable_classes');
  
  runApp(
    const ProviderScope(
      child: ChronosApp(),
    ),
  );
}

class ChronosApp extends StatelessWidget {
  const ChronosApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chronos Timetable',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE94057),
          secondary: Color(0xFF8A2387),
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF121212),
          error: Colors.redAccent,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white60),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          dialBackgroundColor: const Color(0xFF121212),
          dialHandColor: const Color(0xFFE94057),
          dialTextColor: Colors.white,
          entryModeIconColor: const Color(0xFFE94057),
          hourMinuteColor: const Color(0xFF121212),
          hourMinuteTextColor: Colors.white,
          dayPeriodColor: const Color(0xFF121212),
          dayPeriodTextColor: Colors.white,
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const TimetableScreen(),
    );
  }
}
