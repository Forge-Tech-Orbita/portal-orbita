import '../models/notice.dart';

const demoNotices = [
  Notice(
    id: 'technology-week',
    title: 'Semana de Tecnologia Órbita',
    category: NoticeCategory.events,
    summary: 'Palestras e feira no Bloco C',
    body: 'Palestras, workshops e feira de projetos dos alunos.',
    eventDetails: '24/11/2026 · 19:00 · Auditório · Bloco C',
    author: 'Coordenação',
    dateText: 'ontem · 17:40',
  ),
  Notice(
    id: 'enrollment',
    title: 'Matrícula do próximo período',
    shortTitle: 'Matrícula 2027.1',
    category: NoticeCategory.academic,
    summary: 'Inscrições abrem em 01/12 às 8h',
    body: 'As inscrições para o período 2027.1 abrem no portal em 01/12, a partir das 8h.',
    dateText: 'Hoje · 08:12',
  ),
  Notice(
    id: 'november-invoice',
    title: 'Boleto de novembro disponível',
    category: NoticeCategory.financial,
    body: 'A fatura já pode ser emitida na área Financeiro do portal.',
    dateText: '10/11/2026',
  ),
  Notice(
    id: 'lab-maintenance',
    title: 'Manutenção no laboratório 2',
    category: NoticeCategory.academic,
    body: 'Aulas remanejadas para o laboratório 5 durante esta semana.',
    dateText: '16/11/2026',
  ),
];

/// Avisos exibidos no mural recente do Início, na ordem do protótipo.
final recentNotices = [demoNotices[1], demoNotices[0]];
