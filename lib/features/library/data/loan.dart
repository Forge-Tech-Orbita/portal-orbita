class Loan {
  const Loan({
    required this.title,
    required this.author,
    required this.daysRemaining,
    required this.dueSoon,
  });

  final String title;
  final String author;
  final int daysRemaining;
  final bool dueSoon;
}
