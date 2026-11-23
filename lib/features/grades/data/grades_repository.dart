import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/student_profile.dart';
import 'grade.dart';

abstract class GradesRepository {
  Future<List<Grade>> loadGrades(StudentProfile profile);
}

class FirebaseGradesRepository implements GradesRepository {
  @override
  Future<List<Grade>> loadGrades(StudentProfile profile) async {
    final courseId = profile.courseId;
    if (profile.uid.isEmpty || profile.uid.contains('/') || courseId == null) {
      throw StateError('Sessão acadêmica incompleta.');
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('students/${profile.uid}/grades')
        .where('semestreLetivo', isEqualTo: profile.semester)
        .where('cursoId', isEqualTo: courseId)
        .get(const GetOptions(source: Source.server));
    final grades = snapshot.docs
        .map(
          (document) => Grade.fromMap(
            document.id,
            document.data(),
            semester: profile.semester,
            courseId: courseId,
          ),
        )
        .toList();
    grades.sort((a, b) => a.code.compareTo(b.code));
    return grades;
  }
}
