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
  const TaskFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
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
      ),
      home: const HomeScreen(),
    );
  }
}
