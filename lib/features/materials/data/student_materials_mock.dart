import '../../../core/models/learning_material.dart';

const studentMaterialFilters = [
  'IA',
  'Arquitetura',
  'BD II',
  'Requisitos',
  'Curso',
];

const demoStudentMaterials = [
  LearningMaterial(
    id: 'ai-modern-approach',
    title: 'Inteligência Artificial: Uma Abordagem Moderna',
    details: 'Prof. R. Nakamura · cap. 3–4 · 12/11',
    kind: MaterialKind.pdf,
    audiences: ['IA'],
  ),
  LearningMaterial(
    id: 'heuristic-search-notes',
    title: 'Notas de aula · Busca heurística',
    details: 'Prof. R. Nakamura · 1,8 MB · 19/11',
    kind: MaterialKind.pdf,
    audiences: ['IA'],
  ),
  LearningMaterial(
    id: 'c4-model',
    title: 'Documentação do C4 Model',
    details: 'Prof. F. Ramalho · recomendação',
    kind: MaterialKind.link,
    audiences: ['Arquitetura'],
  ),
  LearningMaterial(
    id: 'student-handbook',
    title: 'Manual do Aluno 2026',
    details: 'Coordenação · regras de matrícula e avaliação',
    kind: MaterialKind.pdf,
    audiences: ['Curso'],
  ),
];
