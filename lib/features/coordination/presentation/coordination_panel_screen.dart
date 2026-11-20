import 'package:flutter/material.dart';

import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/account_avatar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/metric_tile.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/coordination_mock.dart';

class CoordinationPanelScreen extends StatelessWidget {
  const CoordinationPanelScreen({
    super.key,
    required this.onPublishEvent,
    required this.onPostMaterial,
    required this.onOpenRiskClasses,
  });

  final VoidCallback onPublishEvent;
  final VoidCallback onPostMaterial;
  final VoidCallback onOpenRiskClasses;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                      'Coordenação · $coordinationCourse',
                      style: textTheme.bodySmall,
                    ),
                    Text(coordinatorName, style: textTheme.titleLarge),
                  ],
                ),
              ),
              const AccountAvatar(
                initials: coordinatorInitials,
                name: coordinatorName,
                role: 'Coordenação',
              ),
              IconButton(
                tooltip: 'Encerrar sessão',
                color: OrbitaTheme.terracotta,
                onPressed: () => signOut(context),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: MetricTile(
                  value: '${coursePanel.activeClasses}',
                  label: 'Turmas ativas',
                ),
              ),
              Expanded(
                child: MetricTile(
                  value: coursePanel.average,
                  label: 'Média geral',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: MetricTile(
                  value: coursePanel.attendance,
                  label: 'Frequência',
                ),
              ),
              Expanded(
                child: MetricTile(
                  value: '${coursePanel.studentsAtRisk}',
                  label: 'Alunos em risco',
                  valueColor: OrbitaTheme.terracotta,
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
                onPressed: onPublishEvent,
                icon: const Icon(Icons.campaign_outlined, size: 18),
                label: const Text('Publicar evento'),
              ),
              OutlinedButton.icon(
                onPressed: onPostMaterial,
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: const Text('Postar material'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Pendências', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          InfoCard(
            icon: Icons.warning_amber_outlined,
            iconColor: OrbitaTheme.alert,
            title:
                '${coursePanel.lowAttendanceStudents} alunos com frequência abaixo de 75%',
            subtitle: 'Dados do sistema acadêmico',
            trailing: const StatusTag(label: 'Atenção', tone: TagTone.danger),
            onTap: onOpenRiskClasses,
          ),
          const SizedBox(height: 8),
          InfoCard(
            icon: Icons.event_outlined,
            title: 'Semana de Tecnologia em $featuredEventDaysLeft dias',
            subtitle:
                'Evento publicado · $featuredEventConfirmations confirmações',
            trailing: const StatusTag(label: 'Evento', tone: TagTone.info),
            onTap: onPublishEvent,
          ),
          const SizedBox(height: 12),
          Text(
            'Indicadores agregados · sem dados pessoais nesta tela',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
