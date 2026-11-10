class Course {
  const Course({
    required this.subject,
    required this.professor,
    required this.credits,
    required this.progress,
    required this.room,
  });

  final String subject;
  final String professor;
  final int credits;
  final int progress;
  final String room;
}
