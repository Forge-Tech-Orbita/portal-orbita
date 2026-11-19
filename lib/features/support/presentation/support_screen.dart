import 'package:flutter/material.dart';

import '../../../core/mock/student_mock.dart';
import '../../../core/theme/orbita_theme.dart';
import '../data/support_ticket.dart';
import '../data/support_tickets_mock.dart';
import 'widgets/new_ticket_sheet.dart';

const _supportFaqs = [
  ('Como emito a 2ª via do boleto?', 'Acesse Financeiro → Gerar 2ª via.'),
  (
    'Como solicito o histórico escolar?',
    'Abra um chamado na Central de Suporte.',
  ),
  ('Onde vejo minha frequência?', 'Acesse Notas → detalhes da disciplina.'),
];

String _formatDateTime(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
      '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 2, vsync: this);
  // shortcut: chamados ficam só no estado da tela, sem persistência.
  final _tickets = [...demoSupportTickets];

  Future<void> _openNewTicket() async {
    final data = await showModalBottomSheet<NewTicketData>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const NewTicketSheet(),
    );
    if (!mounted || data == null) return;

    final ticket = SupportTicket(
      protocol: 'ORB-${1001 + _tickets.length}',
      category: data.category,
      subject: data.subject,
      description: data.description,
      requester: demoStudent.name,
      openedAt: _formatDateTime(DateTime.now()),
    );
    setState(() => _tickets.insert(0, ticket));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Chamado ${ticket.protocol} criado.'),
          action: SnackBarAction(
            label: 'Ver chamados',
            onPressed: () => _tabs.animateTo(1),
          ),
        ),
      );
  }

  void _advanceStatus(int index) {
    final next = _tickets[index].status.next;
    if (next == null) return;
    setState(() => _tickets[index] = _tickets[index].copyWith(status: next));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Central de suporte'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Atendimento'),
            Tab(text: 'Equipe de suporte'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabs,
          children: [
            _AttendanceTab(onNewTicket: _openNewTicket),
            _SupportTeamTab(tickets: _tickets, onAdvance: _advanceStatus),
          ],
        ),
      ),
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab({required this.onNewTicket});

  final VoidCallback onNewTicket;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Atendimento demonstrativo · chamados simulados, sem integração',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            color: OrbitaTheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('FALE COM A SECRETARIA', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Abra um chamado para dúvidas sobre matrícula, documentos, aproveitamento de disciplinas ou requerimentos.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onNewTicket,
                    child: const Text('Abrir novo chamado'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Perguntas frequentes', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            color: OrbitaTheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (question, answer) in _supportFaqs)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(question, style: textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(answer),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportTeamTab extends StatelessWidget {
  const _SupportTeamTab({required this.tickets, required this.onAdvance});

  final List<SupportTicket> tickets;
  final ValueChanged<int> onAdvance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pending = tickets
        .where((ticket) => ticket.status != SupportTicketStatus.resolved)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Fila demonstrativa · status alterado apenas nesta tela',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${tickets.length} chamados · $pending pendentes',
            style: textTheme.titleMedium,
          ),
          for (final (index, ticket) in tickets.indexed) ...[
            const SizedBox(height: 12),
            _TicketCard(ticket: ticket, onAdvance: () => onAdvance(index)),
          ],
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.onAdvance});

  final SupportTicket ticket;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (icon, color) = switch (ticket.status) {
      SupportTicketStatus.open => (
        Icons.mark_email_unread_outlined,
        OrbitaTheme.amber,
      ),
      SupportTicketStatus.inProgress => (
        Icons.support_agent,
        OrbitaTheme.primary,
      ),
      SupportTicketStatus.resolved => (
        Icons.check_circle_outline,
        OrbitaTheme.green,
      ),
    };
    final next = ticket.status.next;

    return Card(
      margin: EdgeInsets.zero,
      color: OrbitaTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(ticket.protocol, style: textTheme.titleSmall),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 4),
                    Text(
                      ticket.status.label,
                      style: textTheme.labelLarge?.copyWith(color: color),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(ticket.subject, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${ticket.category} · ${ticket.requester} · ${ticket.openedAt}',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(ticket.description),
            if (next != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onAdvance,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    next == SupportTicketStatus.inProgress
                        ? 'Iniciar atendimento'
                        : 'Marcar como resolvido',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
