import 'package:flutter/material.dart';

import '../../../core/theme/orbita_theme.dart';
import '../data/grade.dart';
import '../data/grades_mock.dart';
import '../data/grades_summary.dart';
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
  const GradesScreen({super.key, this.grades = demoGrades});

  final List<Grade> grades;

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  _GradeFilter _filter = _GradeFilter.all;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (:average, :approved, :inProgress) = summarizeGrades(widget.grades);
    final grades = widget.grades.where(
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
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (average != null)
                GpaRingProgress(value: average)
              else
                const Text('Média do semestre indisponível'),
              for (final (label, count) in [
                ('Aprovadas', approved),
                ('Cursando', inProgress),
              ])
                Column(
                  children: [
                    Text('$count', style: textTheme.headlineSmall),
                    Text(label, style: textTheme.labelMedium),
                  ],
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
          if (grades.isEmpty)
            Text(switch (_filter) {
              _GradeFilter.all => 'Nenhuma disciplina neste semestre.',
              _GradeFilter.inProgress =>
                'Nenhuma disciplina cursando neste semestre.',
              _GradeFilter.completed =>
                'Nenhuma disciplina concluída neste semestre.',
            }, style: textTheme.bodyMedium),
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
    final color = grade.status == GradeStatus.completed
        ? OrbitaTheme.green
        : OrbitaTheme.terracotta;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: OrbitaTheme.surface,
      child: ExpansionTile(
        title: Text(grade.subject),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(grade.code), Text(grade.status.label)],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            average?.toStringAsFixed(1) ?? 'Pendente',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _StageDetails(number: 1, stage: grade.firstStage),
                const SizedBox(height: 16),
                _StageDetails(number: 2, stage: grade.secondStage),
                const SizedBox(height: 12),
                Text(
                  'Nota final: ${average == null ? 'Pendente' : '${average.toStringAsFixed(1)} de 10'}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
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

class _StageDetails extends StatelessWidget {
  const _StageDetails({required this.number, required this.stage});

  final int number;
  final GradeStage stage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = stage.total;
    final assessments = [
      (label: 'AV$number', value: stage.exam, maximum: stage.examMax),
      (label: 'TED', value: stage.ted, maximum: GradeStage.tedMax),
      if (stage.includesIntegrated)
        (
          label: 'Avaliação Integrada',
          value: stage.integratedAssessment,
          maximum: GradeStage.integratedMax,
        ),
    ];
    final pending = assessments
        .where((assessment) => assessment.value == null)
        .map((assessment) => assessment.label)
        .join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text('$numberª etapa', style: textTheme.titleSmall),
        for (final assessment in assessments)
          _AssessmentRow(
            label: assessment.label,
            value: assessment.value,
            maximum: assessment.maximum,
          ),
        Text(
          total == null
              ? 'Subtotal pendente. Falta lançar: $pending.'
              : 'Subtotal: ${total.toStringAsFixed(1)} de 10',
          style: textTheme.labelLarge,
        ),
      ],
    );
  }
}

class _AssessmentRow extends StatelessWidget {
  const _AssessmentRow({
    required this.label,
    required this.value,
    required this.maximum,
  });

  final String label;
  final double? value;
  final double maximum;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    final formatted = value == null
        ? 'Não informada'
        : '${value.toStringAsFixed(1)} de ${maximum.toStringAsFixed(0)}';

    return Semantics(
      label: '$label: $formatted',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Text('$label: $formatted'),
          if (value != null) LinearProgressIndicator(value: value / maximum),
        ],
      ),
    );
  }
}
