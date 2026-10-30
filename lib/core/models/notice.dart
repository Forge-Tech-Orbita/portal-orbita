enum NoticeCategory {
  academic('Acadêmico'),
  events('Eventos'),
  financial('Financeiro');

  const NoticeCategory(this.label);

  final String label;
}

class Notice {
  const Notice({
    required this.id,
    required this.title,
    required this.category,
    required this.body,
    required this.dateText,
    this.summary,
  });

  final String id;
  final String title;
  final NoticeCategory category;
  final String body;
  final String dateText;
  final String? summary;
}
