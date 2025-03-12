import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Attendance.dart';
import 'Attendancepage.dart';
import 'LeaveTab.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class BottomNavBarScreen extends ConsumerWidget {
  const BottomNavBarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> pages = [
      const AttendanceScreen(),
      const AttendanceLogScreen(),
      const LeaveTabScreen(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(bottomNavIndexProvider.notifier).state = index,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Logs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Leave",
          ),
        ],
      ),
    );
  }
}
