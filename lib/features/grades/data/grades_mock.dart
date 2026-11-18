import 'grade.dart';

const demoGrades = [
  Grade(
    subject: 'Arquitetura de Software',
    code: 'ESW-304',
    firstStage: GradeStage(exam: 5, ted: 2.5, integratedAssessment: 1),
    secondStage: GradeStage(exam: 5.5, ted: 2.5, integratedAssessment: 1),
    frequency: 96,
    status: GradeStatus.completed,
  ),
  Grade(
    subject: 'Inteligência Artificial',
    code: 'ESW-412',
    firstStage: GradeStage(exam: 4.5, ted: 2, integratedAssessment: 0.5),
    secondStage: GradeStage(exam: 5, ted: 2, integratedAssessment: 1),
    frequency: 91,
    status: GradeStatus.completed,
  ),
  Grade(
    subject: 'Banco de Dados II',
    code: 'ESW-298',
    firstStage: GradeStage(exam: 4, ted: 2, integratedAssessment: 0.5),
    secondStage: GradeStage(exam: 4.5, ted: 2, integratedAssessment: 0.5),
    frequency: 88,
    status: GradeStatus.completed,
  ),
  Grade(
    subject: 'Engenharia de Requisitos',
    code: 'ESW-355',
    firstStage: GradeStage(exam: 5.5, ted: 2.5, integratedAssessment: 1),
    secondStage: GradeStage(exam: 6, ted: 2.5, integratedAssessment: 1),
    frequency: 98,
    status: GradeStatus.completed,
  ),
  Grade(
    subject: 'Cálculo Numérico',
    code: 'MAT-210',
    firstStage: GradeStage(exam: 3.5, ted: 1.5, integratedAssessment: 0.5),
    secondStage: GradeStage(),
    frequency: 82,
    status: GradeStatus.inProgress,
  ),
];
