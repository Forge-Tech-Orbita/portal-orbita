class TeachingClass {
  const TeachingClass({
    required this.code,
    required this.subject,
    required this.students,
    required this.room,
    required this.materialCount,
  });

  final String code;
  final String subject;
  final int students;
  final String room;

  /// Materiais já publicados antes desta sessão.
  final int materialCount;
}

class StudentAttendance {
  const StudentAttendance({required this.name, required this.absences});

  final String name;
  final int absences;
}

/// Frequência mínima exigida para aprovação.
const minimumAttendance = 75;

int attendancePercent(StudentAttendance student, int meetings) =>
    ((meetings - student.absences) / meetings * 100).round();

bool isAtRisk(StudentAttendance student, int meetings) =>
    attendancePercent(student, meetings) < minimumAttendance;

class ClassNotice {
  const ClassNotice({
    required this.title,
    required this.classCode,
    required this.date,
    required this.readBy,
  });

  final String title;
  final String classCode;
  final String date;
  final int readBy;
}
