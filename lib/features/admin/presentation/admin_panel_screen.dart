import 'package:flutter/material.dart';

import '../../../core/theme/orbita_colors.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/metric_tile.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/admin.dart';
import '../data/admin_mock.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({
    super.key,
    required this.openTickets,
    required this.urgentTickets,
    required this.pendingRequests,
    required this.criticalAlerts,
    required this.onOpenAudit,
    required this.onOpenUsers,
    required this.onOpenTickets,
  });

  final int openTickets;
  final int urgentTickets;
  final int pendingRequests;
  final List<AuditEntry> criticalAlerts;
  final VoidCallback onOpenAudit;
  final VoidCallback onOpenUsers;
  final VoidCallback onOpenTickets;

  @override
  Widget build(BuildContext context) {
    final colors = OrbitaColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$adminName · $adminRole', style: textTheme.bodySmall),
          const SizedBox(height: 10),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: MetricTile(
                  value: adminPanel.activeAccounts,
                  label: 'Contas ativas',
                ),
              ),
              Expanded(
                child: MetricTile(
                  value: '$pendingRequests',
                  label: 'Solicitações',
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
                  value: '${criticalAlerts.length}',
                  label: 'Alertas',
                  valueColor: colors.secondary,
                ),
              ),
              Expanded(
                child: MetricTile(
                  value: adminPanel.availability,
                  label: 'Disponibilidade',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Alertas de auditoria', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final alert in criticalAlerts)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InfoCard(
                icon: alert.result == AuditResult.blocked
                    ? Icons.warning_amber_outlined
                    : Icons.shield_outlined,
                iconColor: alert.result == AuditResult.blocked
                    ? colors.alert
                    : colors.warning,
                title: '${alert.title} · ${alert.actor}',
                subtitle: '${alert.result.label} · ${alert.time}',
                trailing: StatusTag(
                  label: alert.result == AuditResult.blocked ? 'Alto' : 'Médio',
                  tone: alert.result == AuditResult.blocked
                      ? TagTone.danger
                      : TagTone.warning,
                ),
                onTap: onOpenAudit,
              ),
            ),
          const SizedBox(height: 8),
          Text('Fila de operações', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          InfoCard(
            icon: Icons.group_add_outlined,
            title: '$pendingProfessorAccounts novas contas de professor',
            subtitle: 'Solicitadas pela secretaria',
            trailing: const StatusTag(label: 'Revisar', tone: TagTone.info),
            onTap: onOpenUsers,
          ),
          const SizedBox(height: 8),
          InfoCard(
            icon: Icons.help_outline,
            title: '$openTickets chamados de suporte abertos',
            subtitle: urgentTickets == 0
                ? 'Nenhum urgente'
                : '$urgentTickets urgente · erro ao gerar boleto',
            trailing: StatusTag(
              label: urgentTickets == 0 ? 'Em dia' : 'Urgente',
              tone: urgentTickets == 0 ? TagTone.success : TagTone.danger,
            ),
            onTap: onOpenTickets,
          ),
        ],
      ),
    );
  }
}
