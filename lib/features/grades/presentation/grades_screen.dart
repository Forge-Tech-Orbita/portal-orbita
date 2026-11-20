import 'package:flutter/material.dart';

import '../../../core/widgets/page_heading.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/grade.dart';
import '../data/grades_mock.dart';
import '../data/grades_summary.dart';
import 'widgets/gpa_ring_progress.dart';

enum _GradeFilter {
  all('Todas'),
  inProgress('Cursando'),
  completed('Concluídas');

  const _GradeFilter(this.label);

  final String label;

  bool includes(GradeStatus status) => switch (this) {
    all => true,
    inProgress => status == GradeStatus.inProgress,
    completed => status.isCompleted,
  };
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
    final (:average, :approved, :inProgress, :pending) = summarizeGrades(
      widget.grades,
    );
    final grades = widget.grades.where(
      (grade) => _filter.includes(grade.status),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeading(
            overline: 'Desempenho acadêmico',
            title: 'Notas & frequência',
            subtitle:
                'Notas importadas do sistema acadêmico · resumo calculado',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const GpaRingProgress(value: historicalGpa),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  spacing: 6,
                  children: [
                    for (final (label, count) in [
                      ('Aprovadas (histórico)', historicalApproved + approved),
                      ('Cursando', inProgress),
                      ('Pendentes', pending),
                    ])
                      Row(
                        children: [
                          Expanded(child: Text(label)),
                          Text('$count', style: textTheme.titleSmall),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (average != null) ...[
            const SizedBox(height: 8),
            Text(
              'Média do semestre: ${formatGrade(average)}',
              style: textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: [
                for (final filter in _GradeFilter.values)
                  ChoiceChip(
                    label: Text(
                      filter == _GradeFilter.inProgress
                          ? '${filter.label} ($inProgress)'
                          : filter.label,
                    ),
                    selected: filter == _filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (grades.isEmpty)
            Text(switch (_filter) {
              _GradeFilter.all => 'Nenhuma disciplina neste semestre.',
              _GradeFilter.inProgress =>
                'Nenhuma disciplina cursando neste semestre.',
              _GradeFilter.completed =>
                'Nenhuma disciplina concluída neste semestre.',
            }, style: textTheme.bodyMedium),
          for (final grade in grades)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GradeCard(
                key: ValueKey((_filter, grade.code)),
                grade: grade,
              ),
            ),
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
    final textTheme = Theme.of(context).textTheme;
    final average = grade.average;
    final gradeTag = switch (average) {
      null => const StatusTag(label: 'Pendente', tone: TagTone.neutral),
      < 7 => StatusTag(
        label: '${formatGrade(average)} · abaixo de 7',
        tone: TagTone.warning,
      ),
      _ => StatusTag(label: formatGrade(average), tone: TagTone.success),
    };
    final first = grade.firstStage.total;
    final second = grade.secondStage.total;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(grade.subject, style: textTheme.bodyLarge),
                    Text(grade.code, style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: [
                    StatusTag(
                      label: grade.status.label,
                      tone: switch (grade.status) {
                        GradeStatus.approved => TagTone.success,
                        GradeStatus.failed => TagTone.danger,
                        GradeStatus.completed => TagTone.neutral,
                        GradeStatus.inProgress => TagTone.info,
                      },
                    ),
                    gradeTag,
                  ],
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      for (final (label, value) in [
                        ('AV1', first == null ? '—' : formatGrade(first)),
                        ('AV2', second == null ? '—' : formatGrade(second)),
                        ('Média', average == null ? '—' : formatGrade(average)),
                        ('Freq.', '${grade.frequency}%'),
                      ])
                        Expanded(
                          child: Semantics(
                            label: '$label: $value',
                            excludeSemantics: true,
                            child: Column(
                              children: [
                                Text(label, style: textTheme.bodySmall),
                                Text(value, style: textTheme.titleSmall),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 24),
                  _StageDetails(number: 1, stage: grade.firstStage),
                  const SizedBox(height: 16),
                  _StageDetails(number: 2, stage: grade.secondStage),
                  const SizedBox(height: 12),
                  Text(
                    'Nota final: ${average == null ? 'Pendente' : '${average.toStringAsFixed(1)} de 10'}',
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Frequência: ${grade.frequency}% · Situação: ${grade.status.label}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
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
