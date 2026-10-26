import { Notice } from '../types';

export const notices: Notice[] = [
  {
    id: 'matricula-proximo-periodo',
    title: 'Matrícula do próximo período',
    text: 'As inscrições para o período 2026.2 abrem no portal a partir das 8h.',
    category: 'acad',
    date: 'Hoje · 08:12',
  },
  {
    id: 'semana-tecnologia',
    title: 'Semana de Tecnologia Órbita',
    text: 'Palestras, workshops e feira de projetos dos alunos no Bloco C.',
    category: 'event',
    date: 'Ontem · 17:40',
  },
  {
    id: 'boleto-setembro',
    title: 'Boleto de setembro disponível',
    text: 'A fatura já pode ser emitida na área Financeiro do portal.',
    category: 'fin',
    date: '2 dias atrás',
  },
  {
    id: 'manutencao-lab-2',
    title: 'Manutenção no laboratório 2',
    text: 'Aulas remanejadas para o laboratório 5 durante esta semana.',
    category: 'acad',
    date: '4 dias atrás',
  },
];

/** Rótulos e cores usados nas tags "Acadêmico / Eventos / Financeiro". */
export const noticeCategoryLabel: Record<Notice['category'], string> = {
  acad: 'Acadêmico',
  event: 'Eventos',
  fin: 'Financeiro',
};
