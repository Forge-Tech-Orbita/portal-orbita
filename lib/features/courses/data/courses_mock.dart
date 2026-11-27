import '../../../core/mock/academic_demo.dart';
import 'course.dart';

List<Course> coursesFor(AcademicDemo? demo) => switch (demo) {
  AcademicDemo.informationSystems => demoCourses,
  AcademicDemo.administration => _administrationCourses,
  null => const [],
};

const _administrationCourses = [
  Course(
    subject: peopleManagementSubject,
    professor: peopleManagementProfessor,
    room: peopleManagementRoom,
    credits: 4,
    progress: 72,
  ),
  Course(
    subject: managementAccountingSubject,
    professor: managementAccountingProfessor,
    room: managementAccountingRoom,
    credits: 4,
    progress: 65,
  ),
  Course(
    subject: marketingSubject,
    professor: marketingProfessor,
    room: marketingRoom,
    credits: 4,
    progress: 80,
  ),
];

const demoCourses = [
  Course(
    subject: 'Arquitetura de Software',
    professor: 'Prof. F. Ramalho',
    credits: 4,
    progress: 78,
    room: 'Sala 210',
  ),
  Course(
    subject: 'Inteligência Artificial',
    professor: 'Prof. R. Nakamura',
    credits: 4,
    progress: 70,
    room: 'Sala 304',
  ),
  Course(
    subject: 'Banco de Dados II',
    professor: 'Prof.ª L. Andrade',
    credits: 3,
    progress: 65,
    room: 'Lab 05',
  ),
  Course(
    subject: 'Engenharia de Requisitos',
    professor: 'Prof.ª C. Bezerra',
    credits: 4,
    progress: 82,
    room: 'Sala 212',
  ),
];
