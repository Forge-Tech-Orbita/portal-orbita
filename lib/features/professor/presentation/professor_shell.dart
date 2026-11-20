import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/models/learning_material.dart';
import '../../../core/widgets/materials_board.dart';
import '../../../core/widgets/orbita_bottom_nav.dart';
import '../data/professor.dart';
import '../data/professor_mock.dart';
import 'attendance_screen.dart';
import 'professor_classes_screen.dart';
import 'professor_home_screen.dart';
import 'professor_notice_screen.dart';

const professorNavItems = <OrbitaNavItem>[
  (icon: Icons.home_outlined, label: 'Início'),
  (icon: Icons.group_outlined, label: 'Turmas'),
  (icon: Icons.menu_book_outlined, label: 'Materiais'),
  (icon: Icons.assignment_outlined, label: 'Frequência'),
  (icon: Icons.campaign_outlined, label: 'Avisos'),
];

abstract final class ProfessorTab {
  static const home = 0;
  static const classes = 1;
  static const materials = 2;
  static const attendance = 3;
  static const notices = 4;
}

class ProfessorShell extends StatefulWidget {
  const ProfessorShell({super.key});

  @override
  State<ProfessorShell> createState() => _ProfessorShellState();
}

class _ProfessorShellState extends State<ProfessorShell> {
  int _index = ProfessorTab.home;
  // shortcut: publicações ficam só nesta sessão, sem persistência.
  final _materials = [...professorMaterials];
  final _posted = <LearningMaterial>[];
  final _notices = [...professorNotices];
  var _attendanceClass = professorNextClass.code;
  var _riskOnly = false;

  int _materialCountFor(String code) {
    final base = teachingClasses
        .firstWhere((c) => c.code == code)
        .materialCount;
    return base + _posted.where((m) => m.audiences.contains(code)).length;
  }

  int get _materialTotal =>
      teachingClasses.fold(0, (sum, c) => sum + _materialCountFor(c.code));

  void _openAttendance({String? classCode, bool riskOnly = false}) {
    setState(() {
      _attendanceClass = classCode ?? _attendanceClass;
      _riskOnly = riskOnly;
      _index = ProfessorTab.attendance;
    });
  }

  Future<void> _newMaterial() async {
    final result = await Navigator.of(context)
        .pushNamed(AppRoutes.professorNewMaterial);
    if (!mounted || result is! PublishedMaterial) return;

    setState(() {
      _materials.insert(0, result.material);
      _posted.add(result.material);
      _index = ProfessorTab.materials;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result.notify
                ? 'Material publicado e alunos notificados.'
                : 'Material publicado.',
          ),
        ),
      );
  }

  void _publishNotice(ClassNotice notice) {
    setState(() => _notices.insert(0, notice));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            ProfessorHomeScreen(
              materialTotal: _materialTotal,
              latestNotice: _notices.firstOrNull,
              onPostMaterial: _newMaterial,
              onOpenAttendance: ({bool riskOnly = false}) => _openAttendance(
                classCode: professorNextClass.code,
                riskOnly: riskOnly,
              ),
              onOpenNotices: () =>
                  setState(() => _index = ProfessorTab.notices),
            ),
            ProfessorClassesScreen(
              materialCountFor: _materialCountFor,
              onOpenClass: (code) => _openAttendance(classCode: code),
            ),
            MaterialsBoard(
              subtitle: 'Visível só para os alunos das turmas escolhidas',
              allLabel: 'Todas',
              filters: [for (final c in teachingClasses) c.code],
              materials: _materials,
              onNewMaterial: _newMaterial,
            ),
            AttendanceScreen(
              classCode: _attendanceClass,
              riskOnly: _riskOnly,
              onClassChanged: (code) => setState(() {
                _attendanceClass = code;
                _riskOnly = false;
              }),
              onRiskOnlyChanged: (value) => setState(() => _riskOnly = value),
            ),
            ProfessorNoticeScreen(
              notices: _notices,
              onPublished: _publishNotice,
            ),
          ],
        ),
      ),
      bottomNavigationBar: OrbitaBottomNav(
        currentIndex: _index,
        items: professorNavItems,
        onTap: (index) => setState(() => _index = index),
      ),
    );
  }
}
