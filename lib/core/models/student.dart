class Student {
  const Student({
    required this.name,
    required this.shortName,
    required this.initials,
    required this.course,
    required this.period,
    required this.registration,
    required this.validUntil,
    required this.maskedCpf,
    required this.email,
    required this.maskedPhone,
  });

  final String name;
  final String shortName;
  final String initials;
  final String course;
  final String period;
  final String registration;
  final String validUntil;
  final String maskedCpf;
  final String email;
  final String maskedPhone;
}
