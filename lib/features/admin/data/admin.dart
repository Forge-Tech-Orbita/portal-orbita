enum AccountGroup { academic, administrative }

enum AccountStatus {
  active('Ativo'),
  blocked('Bloqueado'),
  pending('Pendente');

  const AccountStatus(this.label);

  final String label;
}

class AdminAccount {
  const AdminAccount({
    required this.id,
    required this.name,
    required this.detail,
    required this.group,
    required this.status,
  });

  final String id;
  final String name;
  final String detail;
  final AccountGroup group;
  final AccountStatus status;

  AdminAccount copyWith({AccountStatus? status}) => AdminAccount(
    id: id,
    name: name,
    detail: detail,
    group: group,
    status: status ?? this.status,
  );
}

enum TicketStatus {
  open('Aberto', 'Abertos'),
  inProgress('Em andamento', 'Em andamento'),
  resolved('Resolvido', 'Resolvidos');

  const TicketStatus(this.label, this.filterLabel);

  final String label;
  final String filterLabel;

  TicketStatus? get next => switch (this) {
    TicketStatus.open => TicketStatus.inProgress,
    TicketStatus.inProgress => TicketStatus.resolved,
    TicketStatus.resolved => null,
  };
}

enum TicketCategory {
  access('Acesso e login'),
  systemError('Erro no sistema'),
  request('Requerimento');

  const TicketCategory(this.label);

  final String label;
}

enum TicketPriority {
  urgent('Urgente'),
  high('Alta'),
  normal('Normal');

  const TicketPriority(this.label);

  final String label;
}

class AdminTicket {
  const AdminTicket({
    required this.id,
    required this.title,
    required this.requester,
    required this.category,
    required this.area,
    required this.openedAt,
    required this.deadline,
    required this.priority,
    required this.description,
    this.status = TicketStatus.open,
    this.team = 'Equipe de TI',
  });

  final String id;
  final String title;
  final String requester;
  final TicketCategory category;
  final String area;
  final String openedAt;
  final String deadline;
  final TicketPriority priority;
  final String description;
  final TicketStatus status;
  final String team;

  AdminTicket copyWith({TicketStatus? status, String? team}) => AdminTicket(
    id: id,
    title: title,
    requester: requester,
    category: category,
    area: area,
    openedAt: openedAt,
    deadline: deadline,
    priority: priority,
    description: description,
    status: status ?? this.status,
    team: team ?? this.team,
  );
}

enum AuditResult {
  pending('Pendente'),
  success('Sucesso'),
  blocked('Bloqueado'),
  denied('Negado 403');

  const AuditResult(this.label);

  final String label;
}

class AuditEntry {
  const AuditEntry({
    required this.title,
    required this.actor,
    required this.time,
    required this.result,
    this.critical = false,
    this.today = true,
  });

  final String title;
  final String actor;
  final String time;
  final AuditResult result;
  final bool critical;
  final bool today;
}

final _adminEmail = RegExp(r'^adm\.[a-z][a-z0-9.]*@orbita\.edu$');

/// Só contas administrativas (adm.nome@orbita.edu) entram no portal admin.
String? validateAdminEmail(String? value) {
  final email = (value ?? '').trim().toLowerCase();
  if (email.isEmpty) return 'Informe o e-mail administrativo.';
  return _adminEmail.hasMatch(email)
      ? null
      : 'Use uma conta administrativa (adm.nome@orbita.edu).';
}

String? validateMfaCode(String? value) =>
    RegExp(r'^\d{6}$').hasMatch(value ?? '')
    ? null
    : 'Digite os 6 dígitos do autenticador.';

String? validateValidity(String? value, DateTime today) {
  final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$')
      .firstMatch((value ?? '').trim());
  if (match == null) return 'Use o formato dd/mm/aaaa.';
  final day = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final year = int.parse(match[3]!);
  final date = DateTime(year, month, day);
  if (date.day != day || date.month != month) return 'Data inválida.';
  final start = DateTime(today.year, today.month, today.day);
  return date.isAfter(start) ? null : 'A vigência deve terminar no futuro.';
}
