import '../constants/institution_catalog.dart';
import 'student.dart';

class StudentProfile {
  const StudentProfile({
    required this.uid,
    required this.name,
    required this.registration,
    required this.institutionId,
    required this.courseId,
    required this.semester,
    required this.period,
  });

  factory StudentProfile.fromMap(String uid, Map<String, dynamic> data) {
    final name = data['nome'];
    final registration = data['matricula'];
    final institutionId = data['instituicaoId'];
    final courseId = data['cursoId'];
    final semester = data['semestreLetivo'];
    final period = data['periodo'];
    if (uid.isEmpty ||
        name is! String ||
        name.trim().isEmpty ||
        registration is! String ||
        institutionId is! String ||
        semester is! String ||
        !RegExp(r'^[0-9]{4}-[12]$').hasMatch(semester) ||
        period is! int ||
        period < 1 ||
        period > 20 ||
        !data.containsKey('cursoId')) {
      throw const FormatException('Perfil acadêmico inválido.');
    }
    technicalEmail(institutionId, registration);
    if (courseId != null &&
        (courseId is! String ||
            !institutions[institutionId]!.courses.containsKey(courseId))) {
      throw const FormatException('Curso inválido.');
    }
    return StudentProfile(
      uid: uid,
      name: name.trim(),
      registration: registration,
      institutionId: institutionId,
      courseId: courseId as String?,
      semester: semester,
      period: period,
    );
  }

  final String uid;
  final String name;
  final String registration;
  final String institutionId;
  final String? courseId;
  final String semester;
  final int period;

  Student get student => Student(
    name: name,
    shortName: name,
    initials: name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0])
        .join(),
    institution: institutions[institutionId]!.name,
    course:
        institutions[institutionId]!.courses[courseId] ?? 'Curso não definido',
    period: '$periodº período',
    registration: registration,
    validUntil: 'Não informado',
    maskedCpf: 'Não informado',
    email: 'Não informado',
    maskedPhone: 'Não informado',
    phone: '',
    personalEmail: '',
    postalCode: '',
    address: '',
  );
}
