import 'support_ticket.dart';

const supportTicketCategories = [
  'Matrícula',
  'Documentos',
  'Atualização cadastral',
  'Financeiro',
  'Outros',
];

const demoSupportTickets = [
  SupportTicket(
    protocol: 'ORB-1002',
    category: 'Documentos',
    subject: 'Declaração de matrícula para estágio',
    description: 'Preciso da declaração assinada para entregar na empresa.',
    requester: 'Lucas Andrade Pires',
    openedAt: '17/11/2026 14:32',
    status: SupportTicketStatus.inProgress,
  ),
  SupportTicket(
    protocol: 'ORB-1001',
    category: 'Matrícula',
    subject: 'Trancamento de disciplina optativa',
    description: 'Gostaria de trancar a disciplina de Computação Gráfica.',
    requester: 'Beatriz Nogueira Lima',
    openedAt: '12/11/2026 09:05',
    status: SupportTicketStatus.resolved,
  ),
];
