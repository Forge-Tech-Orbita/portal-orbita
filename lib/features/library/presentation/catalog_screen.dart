import 'package:flutter/material.dart';

import '../../../core/theme/orbita_colors.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/loan.dart';
import '../data/loans_mock.dart';

class CatalogQuery {
  const CatalogQuery({this.query = '', this.category = LibraryCategory.all});

  final String query;
  final LibraryCategory category;
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, this.initial = const CatalogQuery()});

  final CatalogQuery initial;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final _search = TextEditingController(text: widget.initial.query);
  late var _category = widget.initial.category;
  // shortcut: reservas ficam só no estado da tela, sem integração com o acervo.
  final _books = [...demoCatalog];

  void _request(int index) {
    final book = _books[index];
    final next = book.availability == BookAvailability.available
        ? BookAvailability.reserved
        : BookAvailability.queued;
    setState(() => _books[index] = book.copyWith(availability: next));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            next == BookAvailability.reserved
                ? 'Reserva de "${book.title}" registrada (simulação).'
                : 'Você entrou na fila de "${book.title}" (simulação).',
          ),
        ),
      );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final query = _search.text.trim();
    final results = [
      for (final (index, book) in _books.indexed)
        if (_category.includes(book.category) &&
            matchesQuery(query, [book.title, book.author]))
          (index, book),
    ];
    final scope = _category == LibraryCategory.all
        ? 'no acervo'
        : 'em ${_category.label}';
    final count =
        '${results.length} ${results.length == 1 ? 'resultado' : 'resultados'}';

    return Scaffold(
      appBar: AppBar(title: const Text('Acervo')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Buscar título, autor ou assunto',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final category in LibraryCategory.values)
                    ChoiceChip(
                      label: Text(category.label),
                      selected: category == _category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                query.isEmpty ? '$count $scope' : '$count para "$query" $scope',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final (index, book) in results)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BookCard(
                    book: book,
                    onRequest: () => _request(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book, required this.onRequest});

  final CatalogBook book;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final colors = OrbitaColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final edition = book.edition;
    final (tone, action) = switch (book.availability) {
      BookAvailability.available => (TagTone.success, 'Reservar'),
      BookAvailability.borrowed => (TagTone.warning, 'Entrar na fila'),
      BookAvailability.reserved => (TagTone.info, null),
      BookAvailability.queued => (TagTone.info, null),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Row(
          children: [
            Icon(Icons.menu_book_outlined, color: colors.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: textTheme.bodyLarge),
                  Text(
                    edition == null ? book.author : '${book.author} · $edition',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusTag(label: book.availability.label, tone: tone),
                  if (action != null)
                    TextButton(
                      onPressed: onRequest,
                      child: Text(action, textAlign: TextAlign.end),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
