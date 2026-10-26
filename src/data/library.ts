import { Book } from '../types';

export const libraryCategories = ['Todos', 'Exatas', 'Computação', 'Humanas', 'Periódicos'];

export const loans: Book[] = [
  { id: 'estruturas-dados', title: 'Estruturas de Dados e Algoritmos', author: 'T. Cormen', dueLabel: '2 dias', dueStatus: 'warn' },
  { id: 'arquitetura-limpa', title: 'Arquitetura Limpa', author: 'R. C. Martin', dueLabel: '12 dias', dueStatus: 'ok' },
  { id: 'redes-neurais', title: 'Redes Neurais e Deep Learning', author: 'I. Goodfellow', dueLabel: '18 dias', dueStatus: 'ok' },
];
