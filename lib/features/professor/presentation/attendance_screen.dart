import 'package:flutter/material.dart';

import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/metric_tile.dart';
import '../../../core/widgets/page_heading.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/professor.dart';
import '../data/professor_mock.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({
    super.key,
    required this.classCode,
    required this.riskOnly,
    required this.onClassChanged,
    required this.onRiskOnlyChanged,
  });

  final String classCode;
  final bool riskOnly;
  final ValueChanged<String> onClassChanged;
  final ValueChanged<bool> onRiskOnlyChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final students = classAttendance[classCode]!;
    final atRisk = students
        .where((student) => isAtRisk(student, professorMeetings))
        .toList();
    final visible = riskOnly ? atRisk : students;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeading(
            overline: 'Somente leitura',
            title: 'Frequência dos alunos',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final teachingClass in teachingClasses)
                ChoiceChip(
                  label: Text(teachingClass.code),
                  selected: teachingClass.code == classCode,
                  onSelected: (_) => onClassChanged(teachingClass.code),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: MetricTile(
                  value: '${classAverageAttendance[classCode]}%',
                  label: 'Média da turma',
                ),
              ),
              Expanded(
                child: MetricTile(
                  value: '${atRisk.length}',
                  label: 'Abaixo de $minimumAttendance%',
                  valueColor: OrbitaTheme.terracotta,
                ),
              ),
              const Expanded(
                child: MetricTile(
                  value: '$professorMeetings',
                  label: 'Encontros',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('Todos'),
                selected: !riskOnly,
                onSelected: (_) => onRiskOnlyChanged(false),
              ),
              ChoiceChip(
                label: Text('Em risco (${atRisk.length})'),
                selected: riskOnly,
                onSelected: (_) => onRiskOnlyChanged(true),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (visible.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Nenhum aluno em risco nesta turma.'),
                    ),
                  for (final student in visible)
                    _AttendanceRow(student: student),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Importado do sistema acadêmico em $attendanceImportedAt. '
            'Correções são feitas lá.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.student});

  final StudentAttendance student;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percent = attendancePercent(student, professorMeetings);
    final risk = isAtRisk(student, professorMeetings);
    final color = risk ? OrbitaTheme.alert : OrbitaTheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(student.name),
                    if (risk)
                      const StatusTag(
                        label: 'Abaixo de 75%',
                        tone: TagTone.danger,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$percent%',
                style: textTheme.titleSmall?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              color: color,
              semanticsLabel: 'Frequência de ${student.name}: $percent%',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${student.absences} faltas em $professorMeetings encontros',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
