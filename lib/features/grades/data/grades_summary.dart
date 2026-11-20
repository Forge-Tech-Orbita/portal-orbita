import 'grade.dart';

({double? average, int approved, int inProgress}) summarizeGrades(
  Iterable<Grade> grades,
) {
  var total = 0.0;
  var graded = 0;
  var approved = 0;
  var inProgress = 0;

  for (final grade in grades) {
    final average = grade.average;
    if (average != null) {
      total += average;
      graded++;
    }
    switch (grade.status) {
      case GradeStatus.approved:
        approved++;
      case GradeStatus.inProgress:
        inProgress++;
      case GradeStatus.completed:
      case GradeStatus.failed:
        break;
    }
  }

  return (
    average: graded == 0 ? null : total / graded,
    approved: approved,
    inProgress: inProgress,
  );
}
