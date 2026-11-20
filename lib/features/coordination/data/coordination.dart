class CourseClass {
  const CourseClass({
    required this.subject,
    required this.code,
    required this.professor,
    required this.average,
    required this.attendance,
    required this.period,
  });

  final String subject;
  final String code;
  final String professor;
  final double average;
  final int attendance;
  final int period;

  /// Turma em risco: média abaixo de 7 ou frequência abaixo de 85%.
  bool get atRisk => average < 7 || attendance < 85;
}

enum PostKind {
  event('Evento'),
  announcement('Comunicado');

  const PostKind(this.label);

  final String label;
}

class CoursePost {
  const CoursePost({
    required this.title,
    required this.kind,
    required this.audience,
    required this.date,
  });

  final String title;
  final PostKind kind;
  final String audience;
  final String date;
}

String formatAverage(double value) =>
    value.toStringAsFixed(1).replaceAll('.', ',');
