import 'package:flutter/material.dart';

import '../../../core/mock/notifications_mock.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/widgets/orbita_bottom_nav.dart';
import '../../auth/data/academic_session.dart';
import '../../grades/data/grades_repository.dart';
import '../../courses/presentation/courses_screen.dart';
import '../../grades/presentation/grades_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../home/presentation/widgets/next_class_card.dart';
import '../../more/presentation/more_screen.dart';
import '../../schedule/data/schedule.dart';
import '../../schedule/data/schedule_mock.dart';
import '../../schedule/presentation/schedule_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.gradesRepository});

  final GradesRepository gradesRepository;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;
  // shortcut: notificações vivem só nesta sessão, sem persistência nem polling.
  final _notifications = ValueNotifier<List<AppNotification>>(
    demoNotifications,
  );

  HomeNextClass? _nextClass() {
    final next = nextClassFrom(demoSchedule, DateTime.now());
    if (next == null) return null;
    return (
      subject: next.lesson.subject,
      details: '${next.lesson.room} · ${next.lesson.professor}',
      when: next.when,
      startsIn: next.startsIn,
    );
  }

  @override
  void dispose() {
    _notifications.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            HomeScreen(nextClass: _nextClass(), notifications: _notifications),
            const ScheduleScreen(),
            GradesScreen(
              repository: widget.gradesRepository,
              profile: AcademicSessionScope.maybeOf(context)?.profile,
            ),
            const CoursesScreen(),
            const MoreScreen(),
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
