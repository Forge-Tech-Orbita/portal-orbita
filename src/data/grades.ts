import { Grade } from '../types';

export const grades: Grade[] = [
  { subject: 'Arquitetura de Software', code: 'ESW-304', av1: 8.5, av2: 9.0, frequency: 96, status: 'concluidas' },
  { subject: 'Inteligência Artificial', code: 'ESW-412', av1: 7.0, av2: 8.0, frequency: 91, status: 'concluidas' },
  { subject: 'Banco de Dados II', code: 'ESW-298', av1: 6.5, av2: 7.0, frequency: 88, status: 'concluidas' },
  { subject: 'Engenharia de Requisitos', code: 'ESW-355', av1: 9.0, av2: 9.5, frequency: 98, status: 'concluidas' },
  { subject: 'Cálculo Numérico', code: 'MAT-210', av1: 5.5, av2: null, frequency: 82, status: 'cursando' },
];

export const gradesSummary = {
  cra: 8.7,
  approved: 18,
  inProgress: 5,
  pending: 0,
};
