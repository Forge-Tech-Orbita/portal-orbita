import '../models/notice.dart';

const demoNotices = [
  Notice(
    id: 'enrollment',
    title: 'Matrícula do próximo período',
    category: NoticeCategory.academic,
    summary: 'Matrícula do próximo período abre dia 15/09 pelo portal.',
    body:
        'As inscrições para o período 2026.2 abrem no portal a partir das 8h.',
    dateText: 'Hoje · 08:12',
  ),
  Notice(
    id: 'technology-week',
    title: 'Semana de Tecnologia Órbita',
    category: NoticeCategory.events,
    summary: 'Semana de Tecnologia com palestras e feira de projetos.',
    body: 'Palestras, workshops e feira de projetos dos alunos no Bloco C.',
    dateText: 'Ontem · 17:40',
  ),
  Notice(
    id: 'september-invoice',
    title: 'Boleto de setembro disponível',
    category: NoticeCategory.financial,
    summary: 'Boleto de setembro disponível para emissão.',
    body: 'A fatura já pode ser emitida na área Financeiro do portal.',
    dateText: '2 dias atrás',
  ),
  Notice(
    id: 'lab-maintenance',
    title: 'Manutenção no laboratório 2',
    category: NoticeCategory.academic,
    body: 'Aulas remanejadas para o laboratório 5 durante esta semana.',
    dateText: '4 dias atrás',
  ),
];
