import '../../../core/models/learning_material.dart';
import 'coordination.dart';

const coordinatorName = 'Prof.ª C. Bezerra';
const coordinatorInitials = 'CB';
const coordinationCourse = 'Eng. de Software';

/// Indicadores agregados do curso, importados do sistema acadêmico.
const coursePanel = (
  activeClasses: 24,
  average: '7,9',
  attendance: '89%',
  studentsAtRisk: 12,
  lowAttendanceStudents: 12,
);

const courseClasses = [
  CourseClass(
    subject: 'Arquitetura de Software',
    code: 'ESW-304-N',
    professor: 'Prof. F. Ramalho',
    average: 8.1,
    attendance: 92,
    period: 6,
  ),
  CourseClass(
    subject: 'Inteligência Artificial',
    code: 'ESW-412-N',
    professor: 'Prof. R. Nakamura',
    average: 7.4,
    attendance: 90,
    period: 6,
  ),
  CourseClass(
    subject: 'Banco de Dados II',
    code: 'ESW-298-N',
    professor: 'Prof.ª L. Andrade',
    average: 6.6,
    attendance: 84,
    period: 4,
  ),
  CourseClass(
    subject: 'Engenharia de Requisitos',
    code: 'ESW-355-N',
    professor: 'Prof.ª C. Bezerra',
    average: 8.7,
    attendance: 93,
    period: 6,
  ),
];

const coordinationAudiences = <AudienceOption>[
  (
    label: 'Curso inteiro · Engenharia de Software',
    audiences: ['Curso inteiro'],
  ),
  (label: '6º período', audiences: ['6º período']),
  (label: 'Calouros', audiences: ['Calouros']),
  (label: '7º e 8º períodos', audiences: ['7º e 8º períodos']),
];

const coordinationMaterials = [
  LearningMaterial(
    id: 'student-handbook',
    title: 'Manual do Aluno 2026',
    details: 'Regras de matrícula e avaliação · Curso inteiro',
    kind: MaterialKind.pdf,
    audiences: ['Curso inteiro'],
  ),
  LearningMaterial(
    id: 'tcc-guide',
    title: 'Guia de TCC · Engenharia de Software',
    details: 'PDF · 3,1 MB · 01/11 · 7º e 8º períodos',
    kind: MaterialKind.pdf,
    audiences: ['7º e 8º períodos'],
  ),
  LearningMaterial(
    id: 'digital-library',
    title: 'Biblioteca digital da instituição',
    details: 'Acesso com login do portal · Curso inteiro',
    kind: MaterialKind.link,
    audiences: ['Curso inteiro'],
  ),
  LearningMaterial(
    id: 'beginner-track',
    title: 'Trilha de estudos para iniciantes',
    details: 'Recomendação da coordenação · Calouros',
    kind: MaterialKind.link,
    audiences: ['Calouros'],
  ),
];

const coursePosts = [
  CoursePost(
    title: 'Semana de Tecnologia Órbita',
    kind: PostKind.event,
    audience: 'curso inteiro',
    date: '17/11',
  ),
  CoursePost(
    title: 'Matrícula 2027.1',
    kind: PostKind.announcement,
    audience: 'curso inteiro',
    date: '12/11',
  ),
];

/// Confirmações do evento em destaque no painel.
const featuredEventConfirmations = 214;
const featuredEventDaysLeft = 5;
