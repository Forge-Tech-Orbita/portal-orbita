import 'package:portal_orbita/features/grades/data/grade.dart';

const demoGrades = [
  Grade(
    subject: 'Arquitetura de Software',
    code: 'ESW-304',
    firstStage: GradeStage.first(exam: 6, ted: 2.6),
    secondStage: GradeStage.second(
      exam: 5.5,
      ted: 2.5,
      integratedAssessment: 1,
    ),
    frequency: 94,
    status: GradeStatus.inProgress,
  ),
  Grade(
    subject: 'Inteligência Artificial',
    code: 'ESW-412',
    firstStage: GradeStage.first(exam: 5, ted: 2),
    secondStage: GradeStage.second(exam: 5, ted: 2, integratedAssessment: 1),
    frequency: 92,
    status: GradeStatus.inProgress,
  ),
  Grade(
    subject: 'Banco de Dados II',
    code: 'ESW-298',
    firstStage: GradeStage.first(exam: 4.5, ted: 2),
    secondStage: GradeStage.second(
      exam: 4.5,
      ted: 2,
      integratedAssessment: 0.5,
    ),
    frequency: 86,
    status: GradeStatus.inProgress,
  ),
  Grade(
    subject: 'Engenharia de Requisitos',
    code: 'ESW-355',
    firstStage: GradeStage.first(exam: 6.5, ted: 2.6),
    secondStage: GradeStage.second(exam: 6, ted: 2.5, integratedAssessment: 1),
    frequency: 92,
    status: GradeStatus.inProgress,
  ),
];
