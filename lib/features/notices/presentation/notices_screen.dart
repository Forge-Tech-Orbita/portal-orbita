import 'package:flutter/material.dart';

import '../../../core/mock/notices_mock.dart';
import '../../../core/models/notice.dart';
import '../../../core/widgets/notice_tile.dart';
import '../../../core/widgets/status_tag.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  // shortcut: confirmação de presença fica só nesta tela, sem persistência.
  final _confirmed = <String>{};

  void _toggle(Notice notice) {
    final confirmed = !_confirmed.contains(notice.id);
    setState(() {
      confirmed ? _confirmed.add(notice.id) : _confirmed.remove(notice.id);
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            confirmed
                ? 'Presença confirmada em ${notice.title}.'
                : 'Confirmação de presença cancelada.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final events = demoNotices.where((notice) => notice.isEvent);
    final others = demoNotices.where((notice) => !notice.isEvent).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mural de avisos')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Comunicados e eventos do curso e da instituição',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              for (final event in events) ...[
                _EventCard(
                  notice: event,
                  confirmed: _confirmed.contains(event.id),
                  onToggle: () => _toggle(event),
                ),
                const SizedBox(height: 4),
              ],
              for (final (index, notice) in others.indexed) ...[
                if (index > 0) const Divider(),
                NoticeTile(notice: notice),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.notice,
    required this.confirmed,
    required this.onToggle,
  });

  final Notice notice;
  final bool confirmed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notice.title, style: textTheme.titleSmall),
            const SizedBox(height: 4),
            const StatusTag(label: 'Evento', tone: TagTone.danger),
            const SizedBox(height: 6),
            Text(notice.body),
            Text(notice.eventDetails!, style: textTheme.bodySmall),
            const SizedBox(height: 10),
            confirmed
                ? OutlinedButton.icon(
                    onPressed: onToggle,
                    icon: const Icon(Icons.check),
                    label: const Text('Presença confirmada'),
                  )
                : FilledButton(
                    onPressed: onToggle,
                    child: const Text('Confirmar presença'),
                  ),
            const SizedBox(height: 6),
            Text(
              '${notice.author} · ${notice.dateText}',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
