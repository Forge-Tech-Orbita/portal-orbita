enum GradeStatus {
  inProgress('Em andamento'),
  completed('Aprovado');

  const GradeStatus(this.label);

  final String label;
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
