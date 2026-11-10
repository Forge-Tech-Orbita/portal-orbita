enum GradeStatus {
  inProgress('Em andamento'),
  completed('Aprovado');

  const GradeStatus(this.label);

  final String label;
}

class Grade {
  const Grade({
    required this.subject,
    required this.code,
    required this.av1,
    required this.av2,
    required this.frequency,
    required this.status,
  });

  final String subject;
  final String code;
  final double av1;
  final double? av2;
  final int frequency;
  final GradeStatus status;

  double? get average {
    final secondGrade = av2;
    return secondGrade == null ? null : (av1 + secondGrade) / 2;
  }
}
