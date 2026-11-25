import '../../../core/mock/academic_demo.dart';
import '../../../core/models/learning_material.dart';

typedef StudentMaterials = ({
  List<String> filters,
  List<LearningMaterial> items,
});

StudentMaterials materialsFor(AcademicDemo? demo) => switch (demo) {
  AcademicDemo.informationSystems => (
    filters: studentMaterialFilters,
    items: demoStudentMaterials,
  ),
  AcademicDemo.administration => (
    filters: _administrationFilters,
    items: _administrationMaterials,
  ),
  null => (filters: const [], items: const []),
};

const _administrationFilters = [
  peopleManagementSubject,
  managementAccountingSubject,
  marketingSubject,
  'Curso',
];

const _administrationMaterials = [
  LearningMaterial(
    id: 'adm-people-management',
    title: 'Guia de Gestão de Pessoas',
    details: '$peopleManagementProfessor · leitura introdutória',
    kind: MaterialKind.pdf,
    audiences: [peopleManagementSubject],
  ),
  LearningMaterial(
    id: 'adm-management-accounting',
    title: 'Exercícios de Contabilidade Gerencial',
    details: '$managementAccountingProfessor · lista de exercícios',
    kind: MaterialKind.pdf,
    audiences: [managementAccountingSubject],
  ),
  LearningMaterial(
    id: 'adm-marketing',
    title: 'Introdução à Pesquisa de Mercado',
    details: '$marketingProfessor · recomendação',
    kind: MaterialKind.link,
    audiences: [marketingSubject],
  ),
  _handbook,
];

const _handbook = LearningMaterial(
  id: 'student-handbook',
  title: 'Manual do Aluno 2026',
  details: 'Coordenação · regras de matrícula e avaliação',
  kind: MaterialKind.pdf,
  audiences: ['Curso'],
);

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
  _handbook,
];
