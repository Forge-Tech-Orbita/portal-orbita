import 'package:flutter/material.dart';

import '../../../core/mock/academic_demo.dart';
import '../../../core/mock/notifications_mock.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/widgets/orbita_bottom_nav.dart';
import '../../auth/data/academic_session.dart';
import '../../grades/data/grades_repository.dart';
import '../../courses/data/courses_mock.dart';
import '../../courses/presentation/courses_screen.dart';
import '../../grades/presentation/grades_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../home/presentation/widgets/next_class_card.dart';
import '../../more/presentation/more_screen.dart';
import '../../schedule/data/schedule.dart';
import '../../schedule/data/schedule_mock.dart';
import '../../schedule/presentation/schedule_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    required this.gradesRepository,
    this.now,
  });

  final DateTime? now;

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

  HomeNextClass? _nextClass(DemoSchedule? schedule, DateTime now) {
    if (schedule == null) return null;
    final next = nextClassFrom(schedule.lessons, now);
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
    final profile = AcademicSessionScope.maybeOf(context)?.profile;
    final demo = academicDemoFor(profile);
    final schedule = scheduleFor(demo);
    final now = widget.now ?? DateTime.now();
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            HomeScreen(
              nextClass: _nextClass(schedule, now),
              notifications: _notifications,
            ),
            ScheduleScreen(
              schedule: schedule,
              semester: profile?.semester,
              now: now,
            ),
            GradesScreen(repository: widget.gradesRepository, profile: profile),
            CoursesScreen(
              courses: coursesFor(demo),
              semester: profile?.semester,
            ),
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
