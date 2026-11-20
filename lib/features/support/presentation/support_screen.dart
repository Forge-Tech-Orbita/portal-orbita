import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/mock/student_mock.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/support_ticket.dart';
import '../data/support_tickets_mock.dart';
import 'new_ticket_screen.dart';

String _formatDateTime(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} · '
      '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // shortcut: chamados ficam só no estado da tela, sem persistência.
  final _tickets = [...demoSupportTickets];
  var _nextNumber = firstNewTicketNumber;

  Future<void> _openNewTicket() async {
    final navigator = Navigator.of(context);
    final data = await navigator.pushNamed(AppRoutes.newTicket);
    if (!mounted || data is! NewTicketData) return;

    final ticket = SupportTicket(
      protocol: ticketProtocol(_nextNumber++),
      category: data.category,
      subject: data.subject,
      description: data.description,
      requester: demoStudent.name,
      openedAt: _formatDateTime(DateTime.now()),
    );
    setState(() => _tickets.insert(0, ticket));
    await navigator.pushNamed(AppRoutes.ticketSent, arguments: ticket);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Central de suporte')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Chamados simulados localmente', style: textTheme.bodySmall),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'FALE COM A SECRETARIA',
                        style: textTheme.labelMedium,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Abra um chamado para dúvidas sobre matrícula, documentos, aproveitamento de disciplinas ou requerimentos.',
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _openNewTicket,
                        icon: const Icon(Icons.add),
                        label: const Text('Abrir novo chamado'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final ticket in _tickets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InfoCard(
                    icon: Icons.description_outlined,
                    title: 'Chamado ${ticket.protocol} · ${ticket.subject}',
                    subtitle:
                        'Aberto em ${ticket.openedAt} · ${ticket.status.label.toLowerCase()}',
                    trailing: StatusTag(
                      label: ticket.status.label,
                      tone: switch (ticket.status) {
                        SupportTicketStatus.open => TagTone.info,
                        SupportTicketStatus.inProgress => TagTone.warning,
                        SupportTicketStatus.resolved => TagTone.success,
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text('Perguntas frequentes', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (question, answer) in supportFaqs)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(question, style: textTheme.bodyLarge),
                              Text(answer, style: textTheme.bodySmall),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
