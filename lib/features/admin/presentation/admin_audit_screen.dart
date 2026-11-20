import 'package:flutter/material.dart';

import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/admin.dart';

enum AuditFilter {
  today('Hoje'),
  week('7 dias'),
  critical('Críticos');

  const AuditFilter(this.label);

  final String label;

  bool matches(AuditEntry entry) => switch (this) {
    AuditFilter.today => entry.today,
    AuditFilter.week => true,
    AuditFilter.critical => entry.critical,
  };
}

TagTone auditTone(AuditResult result) => switch (result) {
  AuditResult.pending => TagTone.warning,
  AuditResult.success => TagTone.success,
  AuditResult.blocked => TagTone.danger,
  AuditResult.denied => TagTone.danger,
};

class AdminAuditScreen extends StatelessWidget {
  const AdminAuditScreen({
    super.key,
    required this.entries,
    required this.filter,
    required this.onFilterChanged,
  });

  final List<AuditEntry> entries;
  final AuditFilter filter;
  final ValueChanged<AuditFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visible = entries.where(filter.matches).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final option in AuditFilter.values)
                ChoiceChip(
                  label: Text(option.label),
                  selected: option == filter,
                  onSelected: (_) => onFilterChanged(option),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  for (final (index, entry) in visible.indexed) ...[
                    if (index > 0) const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            size: 20,
                            color: OrbitaTheme.muted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.title),
                                Text(
                                  '${entry.actor} · ${entry.time}',
                                  style: textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 110),
                            child: StatusTag(
                              label: entry.result.label,
                              tone: auditTone(entry.result),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Registros somente leitura · sem senhas, tokens ou dados pessoais',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
