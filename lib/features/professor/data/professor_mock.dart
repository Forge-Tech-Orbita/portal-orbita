import '../../../core/models/learning_material.dart';
import 'professor.dart';

const professorName = 'Prof. R. Nakamura';
const professorInitials = 'RN';
const professorMeetings = 24;
const attendanceImportedAt = '19/11/2026 às 08:00';

const teachingClasses = [
  TeachingClass(
    code: 'ESW-412-N',
    subject: 'Inteligência Artificial',
    students: 38,
    room: 'Sala 304',
    materialCount: 5,
  ),
  TeachingClass(
    code: 'ESW-430-N',
    subject: 'Aprendizado de Máquina',
    students: 32,
    room: 'Lab 03',
    materialCount: 4,
  ),
  TeachingClass(
    code: 'ESW-412-M',
    subject: 'Inteligência Artificial',
    students: 34,
    room: 'Sala 301',
    materialCount: 3,
  ),
];

/// Próxima aula do professor (grade importada do sistema acadêmico).
const professorNextClass = (
  code: 'ESW-412-N',
  subject: 'Inteligência Artificial',
  details: 'Sala 304 · Bloco C · 38 alunos',
  when: 'Seg · 19:00',
);

/// Amostra da frequência importada; cada turma lista os alunos de destaque.
const classAttendance = <String, List<StudentAttendance>>{
  'ESW-412-N': [
    StudentAttendance(name: 'Marina Duarte Costa', absences: 2),
    StudentAttendance(name: 'Bruno Teixeira Lima', absences: 1),
    StudentAttendance(name: 'Carla Nunes Prado', absences: 7),
    StudentAttendance(name: 'Diego Alves Rocha', absences: 8),
    StudentAttendance(name: 'Elisa Moura Santos', absences: 0),
    StudentAttendance(name: 'Fábio Ramos Leite', absences: 7),
  ],
  'ESW-430-N': [
    StudentAttendance(name: 'Gabriela Souza Melo', absences: 1),
    StudentAttendance(name: 'Henrique Prado Dias', absences: 3),
    StudentAttendance(name: 'Isabela Freitas Lopes', absences: 5),
  ],
  'ESW-412-M': [
    StudentAttendance(name: 'João Pedro Martins', absences: 2),
    StudentAttendance(name: 'Larissa Campos Reis', absences: 4),
    StudentAttendance(name: 'Mateus Oliveira Cruz', absences: 7),
  ],
};

/// Média de frequência das turmas, importada do sistema acadêmico.
const classAverageAttendance = {
  'ESW-412-N': 90,
  'ESW-430-N': 92,
  'ESW-412-M': 89,
};

const professorMaterials = [
  LearningMaterial(
    id: 'ai-modern-approach',
    title: 'Inteligência Artificial: Uma Abordagem Moderna',
    details: 'S. Russell, P. Norvig · cap. 3–4 · ESW-412-N',
    kind: MaterialKind.pdf,
    audiences: ['ESW-412-N'],
  ),
  LearningMaterial(
    id: 'ml-course',
    title: 'Curso de Machine Learning (vídeos)',
    details: 'Recomendação para revisão · ESW-430-N',
    kind: MaterialKind.link,
    audiences: ['ESW-430-N'],
  ),
  LearningMaterial(
    id: 'heuristic-search-notes',
    title: 'Notas de aula · Busca heurística',
    details: 'PDF · 1,8 MB · 12/11 · ESW-412-N e M',
    kind: MaterialKind.pdf,
    audiences: ['ESW-412-N', 'ESW-412-M'],
  ),
  LearningMaterial(
    id: 'scikit-learn-docs',
    title: 'Documentação do scikit-learn',
    details: 'scikit-learn.org · ESW-430-N',
    kind: MaterialKind.link,
    audiences: ['ESW-430-N'],
  ),
];

const professorNotices = [
  ClassNotice(
    title: 'Entrega do projeto prorrogada',
    classCode: 'ESW-412-N',
    date: '18/11',
    readBy: 31,
  ),
  ClassNotice(
    title: 'Aula de revisão na segunda',
    classCode: 'ESW-412-N',
    date: '09/11',
    readBy: 31,
  ),
];
