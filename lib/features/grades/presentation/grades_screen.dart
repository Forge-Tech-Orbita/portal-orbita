import 'package:flutter/material.dart';

import '../../../core/theme/orbita_theme.dart';
import '../data/grade.dart';
import '../data/grades_mock.dart';
import 'widgets/gpa_ring_progress.dart';

enum _GradeFilter {
  all('Todas', null),
  inProgress('Cursando', GradeStatus.inProgress),
  completed('Concluídas', GradeStatus.completed);

  const _GradeFilter(this.label, this.status);

  final String label;
  final GradeStatus? status;
}

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  _GradeFilter _filter = _GradeFilter.all;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final grades = demoGrades.where(
      (grade) => _filter.status == null || grade.status == _filter.status,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('DESEMPENHO ACADÊMICO', style: textTheme.labelMedium),
          Text('Notas & frequência', style: textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text('Resumo demonstrativo', style: textTheme.labelSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              // shortcut: CRA e legenda fixos do protótipo, calcular com histórico acadêmico completo.
              const GpaRingProgress(value: 8.7),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    for (final (label, value) in const [
                      ('Aprovadas', '18'),
                      ('Cursando', '5'),
                      ('Pendentes', '0'),
                    ])
                      Row(
                        children: [
                          Expanded(child: Text(label)),
                          Text(value),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: [
                for (final filter in _GradeFilter.values)
                  ChoiceChip(
                    label: Text(filter.label),
                    selected: filter == _filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final grade in grades)
            _GradeCard(key: ValueKey((_filter, grade.code)), grade: grade),
        ],
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({super.key, required this.grade});

  final Grade grade;

  @override
  Widget build(BuildContext context) {
    final average = grade.average;
    final color = average == null
        ? OrbitaTheme.terracotta
        : (average >= 7 ? OrbitaTheme.green : OrbitaTheme.amber);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: OrbitaTheme.surface,
      child: ExpansionTile(
        title: Text(grade.subject),
        subtitle: Text(grade.code),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            average?.toStringAsFixed(1) ?? 'Cursando',
            style: const TextStyle(color: OrbitaTheme.text),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _AssessmentRow(label: 'AV1', value: grade.av1),
                const SizedBox(height: 8),
                _AssessmentRow(label: 'AV2', value: grade.av2),
                const SizedBox(height: 12),
                Text(
                  'Frequência: ${grade.frequency}% · Situação: ${grade.status.label}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentRow extends StatelessWidget {
  const _AssessmentRow({required this.label, required this.value});

  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) {
    final formatted = value?.toStringAsFixed(1) ?? '—';

    return Semantics(
      label: '$label: ${value == null ? 'Não informada' : '$formatted de 10'}',
      excludeSemantics: true,
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 10),
          Expanded(child: LinearProgressIndicator(value: (value ?? 0) / 10)),
          const SizedBox(width: 10),
          Text(formatted),
        ],
      ),
    );
  }
}
