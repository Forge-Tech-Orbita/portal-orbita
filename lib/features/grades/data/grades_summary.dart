import 'grade.dart';

({double? average, int approved, int inProgress, int pending}) summarizeGrades(
  Iterable<Grade> grades,
) {
  var total = 0.0;
  var graded = 0;
  var approved = 0;
  var inProgress = 0;
  var pending = 0;

  for (final grade in grades) {
    final average = grade.average;
    if (average != null) {
      total += average;
      graded++;
    } else {
      pending++;
    }
    switch (grade.status) {
      case GradeStatus.completed:
        approved++;
      case GradeStatus.inProgress:
        inProgress++;
    }
  }

  return (
    average: graded == 0 ? null : total / graded,
    approved: approved,
    inProgress: inProgress,
    pending: pending,
  );
}
