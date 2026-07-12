import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'timetable_page.dart';
import 'tasks_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    TimetablePage(),
    TasksPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFF2C2C2C),
              width: 1.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: const Color(0xFFE94057),
          unselectedItemColor: const Color(0xFF8E8E8E),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_outlined),
              activeIcon: Icon(Icons.task_alt_rounded),
              label: 'Tasks',
            ),
          ],
        ),
      ),
    );
  }
}
