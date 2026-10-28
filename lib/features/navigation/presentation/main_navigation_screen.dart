import 'package:flutter/material.dart';

import '../../../core/widgets/orbita_bottom_nav.dart';
import '../../courses/presentation/courses_screen.dart';
import '../../grades/presentation/grades_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../more/presentation/more_screen.dart';
import '../../schedule/presentation/schedule_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: const [
            HomeScreen(),
            ScheduleScreen(),
            GradesScreen(),
            CoursesScreen(),
            MoreScreen(),
          ],
        ),
      ),
      bottomNavigationBar: OrbitaBottomNav(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
      ),
    );
  }
}
