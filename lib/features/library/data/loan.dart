enum LibraryCategory {
  all('Todos'),
  exact('Exatas'),
  computing('Computação'),
  humanities('Humanas'),
  periodicals('Periódicos');

  const LibraryCategory(this.label);

  final String label;

  bool includes(LibraryCategory category) => this == all || this == category;
}

class Loan {
  const Loan({
    required this.title,
    required this.author,
    required this.dueDate,
    required this.daysRemaining,
    required this.dueSoon,
    required this.category,
  });

  final String title;
  final String author;
  final String dueDate;
  final int daysRemaining;
  final bool dueSoon;
  final LibraryCategory category;
}

enum BookAvailability {
  available('Disponível'),
  borrowed('Emprestado'),
  reserved('Reservado'),
  queued('Na fila');

  const BookAvailability(this.label);

  final String label;
}

class CatalogBook {
  const CatalogBook({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.availability,
    this.edition,
  });

  final String id;
  final String title;
  final String author;
  final String? edition;
  final LibraryCategory category;
  final BookAvailability availability;

  CatalogBook copyWith({BookAvailability? availability}) => CatalogBook(
    id: id,
    title: title,
    author: author,
    edition: edition,
    category: category,
    availability: availability ?? this.availability,
  );
}

/// Remove acentos e diacríticos comuns para comparação de texto.
String removeDiacritics(String text) {
  const withDiacritics = 'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
  const withoutDiacritics = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    final index = withDiacritics.indexOf(char);
    buffer.write(index >= 0 ? withoutDiacritics[index] : char);
  }
  return buffer.toString();
}

/// Busca simples por título ou autor, sem diferenciar maiúsculas ou acentos.
bool matchesQuery(String query, Iterable<String> fields) {
  final normalized = removeDiacritics(query.trim().toLowerCase());
  if (normalized.isEmpty) return true;
  return fields.any(
    (field) => removeDiacritics(field.toLowerCase()).contains(normalized),
  );
}
