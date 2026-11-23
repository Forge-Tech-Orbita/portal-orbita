import 'package:flutter/material.dart';

import '../../../core/theme/orbita_colors.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/admin.dart';
import '../data/admin_mock.dart';
import 'admin_login_screen.dart';

TagTone priorityTone(TicketPriority priority) => switch (priority) {
  TicketPriority.urgent => TagTone.danger,
  TicketPriority.high => TagTone.warning,
  TicketPriority.normal => TagTone.neutral,
};

class AdminTicketsScreen extends StatefulWidget {
  const AdminTicketsScreen({
    super.key,
    required this.tickets,
    required this.onAdvance,
    required this.onForward,
  });

  final List<AdminTicket> tickets;
  final ValueChanged<AdminTicket> onAdvance;
  final void Function(AdminTicket ticket, String team) onForward;

  @override
  State<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  var _status = TicketStatus.open;
  TicketCategory? _category;
  String? _expandedId = adminTickets.first.id;

  Future<void> _reply(AdminTicket ticket) async {
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => _ReplyDialog(ticket: ticket),
    );
    if (!mounted || sent != true) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Resposta enviada em ${ticket.id} (simulação).'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visible = widget.tickets.where(
      (ticket) =>
          ticket.status == _status &&
          (_category == null || ticket.category == _category),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Suporte técnico e requerimentos sobre o portal',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final status in TicketStatus.values)
                ChoiceChip(
                  label: Text(
                    status == TicketStatus.open
                        ? '${status.filterLabel} (${widget.tickets.where((t) => t.status == status).length})'
                        : status.filterLabel,
                  ),
                  selected: _status == status,
                  onSelected: (_) => setState(() => _status = status),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('Todas'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final category in TicketCategory.values)
                ChoiceChip(
                  label: Text(category.label),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Nenhum chamado neste filtro.'),
            ),
          for (final ticket in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TicketCard(
                ticket: ticket,
                expanded: _expandedId == ticket.id,
                onToggle: () => setState(
                  () =>
                      _expandedId = _expandedId == ticket.id ? null : ticket.id,
                ),
                onAdvance: () => widget.onAdvance(ticket),
                onReply: () => _reply(ticket),
                onForward: (team) => widget.onForward(ticket, team),
              ),
            ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.expanded,
    required this.onToggle,
    required this.onAdvance,
    required this.onReply,
    required this.onForward,
  });

  final AdminTicket ticket;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onAdvance;
  final VoidCallback onReply;
  final ValueChanged<String> onForward;

  @override
  Widget build(BuildContext context) {
    final colors = OrbitaColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final next = ticket.status.next;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  if (!expanded) ...[
                    Icon(Icons.help_outline, color: colors.primary),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ticket.id} · ${ticket.title}',
                          style: textTheme.titleSmall,
                        ),
                        if (!expanded)
                          Text(
                            '${ticket.requester} · ${ticket.category.label}',
                            style: textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      alignment: WrapAlignment.end,
                      children: [
                        StatusTag(
                          label: ticket.priority.label,
                          tone: priorityTone(ticket.priority),
                        ),
                        if (!expanded)
                          StatusTag(
                            label: ticket.status.label,
                            tone: TagTone.neutral,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (label, value) in [
                    ('Aberto por', ticket.requester),
                    ('Categoria', '${ticket.category.label} · ${ticket.area}'),
                    ('Aberto em', ticket.openedAt),
                    ('Prazo de resposta', ticket.deadline),
                    ('Status', ticket.status.label),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 12,
                        runSpacing: 2,
                        children: [
                          Text(label),
                          Text(
                            value,
                            style: label == 'Prazo de resposta'
                                ? TextStyle(color: colors.alert)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(ticket.description, style: textTheme.bodySmall),
                  ),
                  const SizedBox(height: 10),
                  LabeledField(
                    label: 'Encaminhar para',
                    child: DropdownButtonFormField<String>(
                      initialValue: ticket.team,
                      isExpanded: true,
                      items: [
                        for (final team in adminTeams)
                          DropdownMenuItem(value: team, child: Text(team)),
                      ],
                      onChanged: (team) {
                        if (team != null && team != ticket.team) {
                          onForward(team);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onReply,
                        icon: const Icon(Icons.send_outlined, size: 18),
                        label: const Text('Responder'),
                      ),
                      if (next != null)
                        FilledButton.icon(
                          style: adminButtonStyle(context),
                          onPressed: onAdvance,
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(
                            next == TicketStatus.inProgress
                                ? 'Assumir'
                                : 'Marcar como resolvido',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReplyDialog extends StatefulWidget {
  const _ReplyDialog({required this.ticket});

  final AdminTicket ticket;

  @override
  State<_ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<_ReplyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Responder ${widget.ticket.id}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _message,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Mensagem ao solicitante',
          ),
          validator: (value) =>
              (value ?? '').trim().length < 5 ? 'Escreva a resposta.' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: adminButtonStyle(context),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(true);
            }
          },
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
