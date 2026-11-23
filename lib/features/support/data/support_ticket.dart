enum SupportTicketStatus {
  open('Aberto'),
  inProgress('Em análise'),
  resolved('Resolvido');

  const SupportTicketStatus(this.label);

  final String label;

  SupportTicketStatus? get next => switch (this) {
    SupportTicketStatus.open => SupportTicketStatus.inProgress,
    SupportTicketStatus.inProgress => SupportTicketStatus.resolved,
    SupportTicketStatus.resolved => null,
  };
}

class SupportTicket {
  const SupportTicket({
    required this.protocol,
    required this.category,
    required this.subject,
    required this.description,
    required this.requester,
    required this.openedAt,
    this.status = SupportTicketStatus.open,
  });

  final String protocol;
  final String category;
  final String subject;
  final String description;
  final String requester;
  final String openedAt;
  final SupportTicketStatus status;

  SupportTicket copyWith({SupportTicketStatus? status}) => SupportTicket(
    protocol: protocol,
    category: category,
    subject: subject,
    description: description,
    requester: requester,
    openedAt: openedAt,
    status: status ?? this.status,
  );
}
