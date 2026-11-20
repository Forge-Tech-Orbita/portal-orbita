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
    this.shortTitle,
    this.summary,
    this.eventDetails,
    this.author,
  });

  final String id;
  final String title;
  final NoticeCategory category;
  final String body;
  final String dateText;

  /// Título curto usado no mural recente do Início.
  final String? shortTitle;
  final String? summary;

  /// Data, horário e local quando o aviso é um evento com presença.
  final String? eventDetails;
  final String? author;

  bool get isEvent => eventDetails != null;
}
