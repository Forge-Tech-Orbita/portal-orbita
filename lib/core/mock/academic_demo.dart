import '../models/student_profile.dart';

enum AcademicDemo { informationSystems, administration }

const demoSemester = '2026-2';

AcademicDemo? academicDemoFor(StudentProfile? profile) {
  if (profile == null || profile.semester != demoSemester) return null;
  return switch ((profile.institutionId, profile.courseId)) {
    ('inst-demo', 'si') ||
    ('inst-horizonte', 'si') => AcademicDemo.informationSystems,
    ('inst-demo', 'adm') => AcademicDemo.administration,
    _ => null,
  };
}

const peopleManagementSubject = 'Gestão de Pessoas';
const peopleManagementProfessor = 'Prof.ª M. Costa';
const peopleManagementRoom = 'Sala 101';
const managementAccountingSubject = 'Contabilidade Gerencial';
const managementAccountingProfessor = 'Prof. P. Lima';
const managementAccountingRoom = 'Sala 102';
const marketingSubject = 'Marketing';
const marketingProfessor = 'Prof.ª A. Rocha';
const marketingRoom = 'Sala 103';
