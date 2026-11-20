enum MaterialKind {
  pdf('PDF', 'Abrir PDF'),
  link('Link', 'Abrir link');

  const MaterialKind(this.label, this.action);

  final String label;
  final String action;
}

/// Livro em PDF ou link recomendado por professor ou coordenação.
class LearningMaterial {
  const LearningMaterial({
    required this.id,
    required this.title,
    required this.details,
    required this.kind,
    required this.audiences,
  });

  final String id;
  final String title;
  final String details;
  final MaterialKind kind;

  /// Turmas, disciplinas ou públicos que veem o material; usados nos filtros.
  final List<String> audiences;
}

/// Material publicado e se os alunos devem ser notificados.
typedef PublishedMaterial = ({LearningMaterial material, bool notify});

/// Opção de público: rótulo exibido e públicos gravados no material.
typedef AudienceOption = ({String label, List<String> audiences});
