import 'support_ticket.dart';

const supportTicketCategories = [
  'Documentos e declarações',
  'Matrícula',
  'Financeiro',
  'Acesso e login',
  'Outros',
];

/// Próximo número sequencial dos protocolos simulados (#2026-NNNN).
const firstNewTicketNumber = 418;

String ticketProtocol(int number) =>
    '#2026-${number.toString().padLeft(4, '0')}';

const demoSupportTickets = [
  SupportTicket(
    protocol: '#2026-0412',
    category: 'Documentos e declarações',
    subject: 'Histórico escolar',
    description: 'Preciso do histórico escolar atualizado para o estágio.',
    requester: 'Marina Duarte Costa',
    openedAt: '12/11',
    status: SupportTicketStatus.inProgress,
  ),
];

const supportFaqs = [
  ('Como emito a 2ª via do boleto?', 'Acesse Financeiro → Boleto (2ª via).'),
  (
    'Como solicito o histórico escolar?',
    'Abra um chamado na Central de Suporte.',
  ),
  ('Onde vejo minha frequência?', 'Acesse Notas → toque na disciplina.'),
];
