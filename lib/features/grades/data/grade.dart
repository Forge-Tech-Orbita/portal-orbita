enum GradeStatus {
  inProgress('Cursando'),
  completed('Concluído'),
  approved('Aprovado'),
  failed('Reprovado');

  const GradeStatus(this.label);

  final String label;

  bool get isCompleted => this != inProgress;
}

class GradeStage {
  const GradeStage.first({double? exam, double? ted})
    : this._(exam: exam, ted: ted, includesIntegrated: false);

  const GradeStage.second({
    double? exam,
    double? ted,
    double? integratedAssessment,
  }) : this._(
         exam: exam,
         ted: ted,
         integratedAssessment: integratedAssessment,
         includesIntegrated: true,
       );

  const GradeStage._({
    this.exam,
    this.ted,
    this.integratedAssessment,
    required this.includesIntegrated,
  }) : assert(
         exam == null || (exam >= 0 && exam <= (includesIntegrated ? 6 : 7)),
       ),
       assert(ted == null || (ted >= 0 && ted <= tedMax)),
       assert(
         integratedAssessment == null ||
             (integratedAssessment >= 0 &&
                 integratedAssessment <= integratedMax),
       );

  double get examMax => includesIntegrated ? 6 : 7;
  static const double tedMax = 3;
  static const double integratedMax = 1;

  final bool includesIntegrated;
  final double? exam;
  final double? ted;
  final double? integratedAssessment;

  double? get total {
    final exam = this.exam;
    final ted = this.ted;
    final integrated = integratedAssessment;
    if (exam == null || ted == null) return null;
    if (!includesIntegrated) return exam + ted;
    if (integrated == null) return null;
    return exam + ted + integrated;
  }
}

class Grade {
  const Grade({
    required this.subject,
    required this.code,
    required this.firstStage,
    required this.secondStage,
    required this.frequency,
    required this.status,
  });

  factory Grade.fromMap(
    String id,
    Map<String, dynamic> data, {
    required String semester,
    required String courseId,
  }) {
    _gradeFields(data, const {
      'semestreLetivo',
      'cursoId',
      'subject',
      'code',
      'firstStage',
      'secondStage',
      'frequency',
      'status',
    });
    final subject = data['subject'];
    final code = data['code'];
    final frequency = data['frequency'];
    final status = data['status'];
    if (!RegExp(r'^[0-9]{4}-[12]$').hasMatch(semester) ||
        !RegExp(r'^[a-z0-9-]{1,30}$').hasMatch(courseId) ||
        data['semestreLetivo'] != semester ||
        data['cursoId'] != courseId ||
        subject is! String ||
        subject.trim().isEmpty ||
        subject.length > 120 ||
        code is! String ||
        code.length > 30 ||
        !RegExp(r'^[A-Z0-9]+(?:-[A-Z0-9]+)*$').hasMatch(code) ||
        id != '${semester}_${courseId}_$code' ||
        frequency is! int ||
        frequency < 0 ||
        frequency > 100 ||
        status is! String ||
        !GradeStatus.values.any((value) => value.name == status)) {
      throw const FormatException('Nota inválida.');
    }
    final first = _gradeFields(data['firstStage'], const {'exam', 'ted'});
    final second = _gradeFields(data['secondStage'], const {
      'exam',
      'ted',
      'integratedAssessment',
    });
    return Grade(
      subject: subject.trim(),
      code: code,
      firstStage: GradeStage.first(
        exam: _gradeScore(first['exam'], 7),
        ted: _gradeScore(first['ted'], GradeStage.tedMax),
      ),
      secondStage: GradeStage.second(
        exam: _gradeScore(second['exam'], 6),
        ted: _gradeScore(second['ted'], GradeStage.tedMax),
        integratedAssessment: _gradeScore(
          second['integratedAssessment'],
          GradeStage.integratedMax,
        ),
      ),
      frequency: frequency,
      status: GradeStatus.values.byName(status),
    );
  }

  final String subject;
  final String code;
  final GradeStage firstStage;
  final GradeStage secondStage;
  final int frequency;
  final GradeStatus status;

  double? get average {
    final first = firstStage.total;
    final second = secondStage.total;
    if (first == null || second == null) return null;
    return (first + second) / 2;
  }
}

Map<Object?, Object?> _gradeFields(Object? value, Set<String> fields) {
  if (value is! Map ||
      value.length != fields.length ||
      !fields.every(value.containsKey)) {
    throw const FormatException('Campos da nota inválidos.');
  }
  return value.cast<Object?, Object?>();
}

double? _gradeScore(Object? value, double maximum) {
  if (value == null) return null;
  if (value is! num || !value.isFinite || value < 0 || value > maximum) {
    throw const FormatException('Componente da nota inválido.');
  }
  return value.toDouble();
}

/// Formata nota com vírgula: uma casa decimal, ou duas quando necessário.
String formatGrade(double value) {
  final hundredths = (value * 100).round();
  final digits = hundredths % 10 == 0 ? 1 : 2;
  return (hundredths / 100).toStringAsFixed(digits).replaceAll('.', ',');
}
