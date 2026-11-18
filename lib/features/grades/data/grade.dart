enum GradeStatus {
  inProgress('Em andamento'),
  completed('Aprovado');

  const GradeStatus(this.label);

  final String label;
}

class GradeStage {
  const GradeStage({this.exam, this.ted, this.integratedAssessment})
    : assert(exam == null || (exam >= 0 && exam <= examMax)),
      assert(ted == null || (ted >= 0 && ted <= tedMax)),
      assert(
        integratedAssessment == null ||
            (integratedAssessment >= 0 &&
                integratedAssessment <= integratedMax),
      );

  static const double examMax = 6;
  static const double tedMax = 3;
  static const double integratedMax = 1;

  final double? exam;
  final double? ted;
  final double? integratedAssessment;

  double? get total {
    final exam = this.exam;
    final ted = this.ted;
    final integrated = integratedAssessment;
    if (exam == null || ted == null || integrated == null) return null;
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
