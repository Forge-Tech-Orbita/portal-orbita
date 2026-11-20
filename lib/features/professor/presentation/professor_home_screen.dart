import 'package:flutter/material.dart';

import '../../../core/widgets/account_avatar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/metric_tile.dart';
import '../../../core/widgets/page_heading.dart';
import '../../../core/widgets/status_tag.dart';
import '../../../core/theme/orbita_colors.dart';
import '../data/professor.dart';
import '../data/professor_mock.dart';

class ProfessorHomeScreen extends StatelessWidget {
  const ProfessorHomeScreen({
    super.key,
    required this.materialTotal,
    required this.latestNotice,
    required this.onPostMaterial,
    required this.onOpenAttendance,
    required this.onOpenNotices,
  });

  final int materialTotal;
  final ClassNotice? latestNotice;
  final VoidCallback onPostMaterial;

  /// Abre a frequência; `riskOnly` filtra os alunos abaixo de 75%.
  final void Function({bool riskOnly}) onOpenAttendance;
  final VoidCallback onOpenNotices;

  @override
  Widget build(BuildContext context) {
    final colors = OrbitaColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final nextCode = professorNextClass.code;
    final atRisk = classAttendance[nextCode]!
        .where((student) => isAtRisk(student, professorMeetings))
        .length;
    final students = teachingClasses.fold(0, (sum, c) => sum + c.students);
    final notice = latestNotice;
    final noticeClass = teachingClasses
        .where((c) => c.code == notice?.classCode)
        .firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${greetingForHour(DateTime.now().hour)} · Professor',
                      style: textTheme.bodySmall,
                    ),
                    Text(professorName, style: textTheme.titleLarge),
                  ],
                ),
              ),
              const AccountAvatar(
                initials: professorInitials,
                name: professorName,
                role: 'Professor',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: MetricTile(
                  value: '${teachingClasses.length}',
                  label: 'Turmas',
                ),
              ),
              Expanded(
                child: MetricTile(value: '$materialTotal', label: 'Materiais'),
              ),
              Expanded(
                child: MetricTile(value: '$students', label: 'Alunos'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Próxima aula', style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${professorNextClass.subject} · $nextCode',
                              style: textTheme.titleSmall,
                            ),
                            Text(
                              professorNextClass.details,
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          professorNextClass.when,
                          textAlign: TextAlign.end,
                          style: textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: onPostMaterial,
                        icon: const Icon(Icons.upload_outlined, size: 18),
                        label: const Text('Postar material'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onOpenAttendance,
                        icon: const Icon(Icons.assignment_outlined, size: 18),
                        label: const Text('Ver frequência'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Atenção', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          InfoCard(
            icon: Icons.warning_amber_outlined,
            iconColor: colors.alert,
            title: '$atRisk alunos abaixo de $minimumAttendance% em IA',
            subtitle: 'Frequência importada do sistema acadêmico',
            trailing: const StatusTag(label: 'Risco', tone: TagTone.danger),
            onTap: () => onOpenAttendance(riskOnly: true),
          ),
          if (notice != null) ...[
            const SizedBox(height: 8),
            InfoCard(
              icon: Icons.campaign_outlined,
              title: noticeClass == null
                  ? 'Comunicado lido por ${notice.readBy}'
                  : 'Comunicado lido por ${notice.readBy} de ${noticeClass.students}',
              subtitle: '${notice.title} · ${notice.classCode}',
              trailing: const StatusTag(
                label: 'Publicado',
                tone: TagTone.success,
              ),
              onTap: onOpenNotices,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Notas e chamada são lançadas no sistema acadêmico da instituição.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
