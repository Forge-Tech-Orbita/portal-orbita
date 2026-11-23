import 'package:portal_orbita/core/models/student_profile.dart';
import 'package:portal_orbita/features/grades/data/grade.dart';
import 'package:portal_orbita/features/grades/data/grades_repository.dart';

import 'grades_fixtures.dart';

const gradesProfile = StudentProfile(
  uid: 'student-a',
  name: 'Aluno',
  registration: '202600001',
  institutionId: 'inst-demo',
  courseId: 'si',
  semester: '2026-2',
  period: 4,
);

class FakeGradesRepository implements GradesRepository {
  List<Grade> grades = demoGrades;
  Future<List<Grade>>? pending;
  Object? error;
  final calls = <StudentProfile>[];

  @override
  Future<List<Grade>> loadGrades(StudentProfile profile) async {
    calls.add(profile);
    if (error != null) throw error!;
    return pending ?? grades;
  }
}
