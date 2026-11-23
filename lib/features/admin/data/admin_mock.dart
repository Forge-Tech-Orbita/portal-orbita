import 'admin.dart';

const adminName = 'Ana Ribeiro';
const adminRole = 'Superadministradora';
const adminEmail = 'adm.ana@orbita.edu';

/// Indicadores do portal, lidos do monitoramento.
const adminPanel = (activeAccounts: '1.284', availability: '99,8%');

const adminAccounts = [
  AdminAccount(
    id: 'marina',
    name: 'Marina Duarte Costa',
    detail: 'Aluno · 2023104567',
    group: AccountGroup.academic,
    status: AccountStatus.active,
  ),
  AdminAccount(
    id: 'nakamura',
    name: 'R. Nakamura',
    detail: 'Professor · 3 turmas',
    group: AccountGroup.academic,
    status: AccountStatus.active,
  ),
  AdminAccount(
    id: 'bezerra',
    name: 'C. Bezerra',
    detail: 'Coordenação · Eng. de Software',
    group: AccountGroup.academic,
    status: AccountStatus.active,
  ),
  AdminAccount(
    id: 'joao',
    name: 'João P. Silva',
    detail: 'Aluno · 2021...',
    group: AccountGroup.academic,
    status: AccountStatus.blocked,
  ),
  AdminAccount(
    id: 'invite-professor',
    name: 'Novo professor (convite)',
    detail: 'Enviado em 10/11',
    group: AccountGroup.academic,
    status: AccountStatus.pending,
  ),
  AdminAccount(
    id: 'adm-ana',
    name: 'Ana Ribeiro',
    detail: 'Superadministradora · adm.ana',
    group: AccountGroup.administrative,
    status: AccountStatus.active,
  ),
  AdminAccount(
    id: 'adm-lucas',
    name: 'Lucas Moreira',
    detail: 'Suporte N1 · adm.lucas',
    group: AccountGroup.administrative,
    status: AccountStatus.active,
  ),
];

/// Contas de professor solicitadas pela secretaria, aguardando revisão.
const pendingProfessorAccounts = 4;

const adminTickets = [
  AdminTicket(
    id: '#SUP-0231',
    title: 'Erro ao gerar boleto',
    requester: 'Marina D. Costa · Aluno',
    category: TicketCategory.systemError,
    area: 'Financeiro',
    openedAt: '19/11/2026 · 14:02',
    deadline: 'vence em 2 h',
    priority: TicketPriority.urgent,
    description: 'Ao tocar em "Boleto (2ª via)" aparece a mensagem "Falha ao gerar documento". Testado no Android e na Web.',
  ),
  AdminTicket(
    id: '#SUP-0229',
    title: 'Não recebo o código de acesso',
    requester: 'Prof. R. Nakamura · Professor',
    category: TicketCategory.access,
    area: 'Login',
    openedAt: '19/11/2026 · 09:40',
    deadline: 'vence em 6 h',
    priority: TicketPriority.high,
    description: 'O código de verificação por e-mail não chega desde ontem.',
  ),
  AdminTicket(
    id: '#REQ-0087',
    title: 'Exportar frequência em planilha',
    requester: 'Prof.ª C. Bezerra · Coordenação',
    category: TicketCategory.request,
    area: 'Relatórios',
    openedAt: '18/11/2026 · 16:15',
    deadline: 'vence em 2 dias',
    priority: TicketPriority.normal,
    description: 'Solicita exportação da frequência das turmas em planilha.',
  ),
  AdminTicket(
    id: '#SUP-0226',
    title: 'Foto de perfil não atualiza',
    requester: 'Bruno T. Lima · Aluno',
    category: TicketCategory.systemError,
    area: 'Perfil',
    openedAt: '18/11/2026 · 11:20',
    deadline: 'vence em 1 dia',
    priority: TicketPriority.normal,
    description: 'Após escolher a foto na galeria, a carteirinha não muda.',
  ),
  AdminTicket(
    id: '#REQ-0085',
    title: 'Liberar acesso de monitor',
    requester: 'Prof. F. Ramalho · Professor',
    category: TicketCategory.request,
    area: 'Permissões',
    openedAt: '17/11/2026 · 10:05',
    deadline: 'vence em 3 dias',
    priority: TicketPriority.normal,
    description: 'Solicita que o monitor da disciplina veja os materiais.',
  ),
  AdminTicket(
    id: '#SUP-0219',
    title: 'Senha expirada',
    requester: 'Larissa C. Reis · Aluno',
    category: TicketCategory.access,
    area: 'Login',
    openedAt: '15/11/2026 · 08:30',
    deadline: 'concluído',
    priority: TicketPriority.normal,
    description: 'Senha redefinida pela equipe.',
    status: TicketStatus.resolved,
  ),
];

const adminTeams = ['Equipe de TI', 'Secretaria acadêmica', 'Financeiro'];

const adminRoles = [
  'Administrador de TI',
  'Suporte N1',
  'Auditor (somente leitura)',
];

const auditEntries = [
  AuditEntry(
    title: 'Pedido de papel: Admin TI',
    actor: 'adm.ana → adm.lucas',
    time: '20:30',
    result: AuditResult.pending,
  ),
  AuditEntry(
    title: 'Material publicado · Guia de TCC',
    actor: 'coord. C. Bezerra',
    time: '20:05',
    result: AuditResult.success,
  ),
  AuditEntry(
    title: 'Login admin com MFA',
    actor: 'adm.ana',
    time: '19:59',
    result: AuditResult.success,
  ),
  AuditEntry(
    title: 'Login acadêmico falho (8x)',
    actor: 'conta 2021...',
    time: '19:58',
    result: AuditResult.blocked,
    critical: true,
  ),
  AuditEntry(
    title: 'Evento publicado · Semana de Tecnologia',
    actor: 'coord. C. Bezerra',
    time: '19:40',
    result: AuditResult.success,
  ),
  AuditEntry(
    title: 'Token acadêmico na API admin',
    actor: 'origem app.orbita.edu',
    time: '18:12',
    result: AuditResult.denied,
    critical: true,
  ),
  AuditEntry(
    title: 'Papel removido · Suporte N1',
    actor: 'adm.ana → adm.paulo',
    time: '16/11 · 10:02',
    result: AuditResult.success,
    today: false,
  ),
  AuditEntry(
    title: 'Exportação de auditoria',
    actor: 'adm.ana',
    time: '14/11 · 17:45',
    result: AuditResult.success,
    today: false,
  ),
];
