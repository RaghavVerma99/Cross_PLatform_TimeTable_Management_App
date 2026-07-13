import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local Hive database
  await Hive.initFlutter();
  await Hive.openBox('tasks');
  await Hive.openBox('timetable');
  
  runApp(
    const ProviderScope(
      child: TaskFlowApp(),
    ),
  );
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000), // Apple OLED Black
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0A84FF),      // Apple System Blue
          secondary: Color(0xFF5E5CE6),    // Apple System Indigo
          surface: Color(0xFF1C1C1E),      // Apple System Gray 6
          error: Color(0xFFFF453A),        // Apple System Red
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5, // SF Pro style tighter letter spacing
          ),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFFEBEBF5)),
        ),
        dialogBackgroundColor: const Color(0xFF1C1C1E),
      ),
      home: const HomeScreen(),
    );
  }
}

