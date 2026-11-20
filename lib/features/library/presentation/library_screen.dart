import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/orbita_colors.dart';
import '../../../core/widgets/page_heading.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/loan.dart';
import '../data/loans_mock.dart';
import 'catalog_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _search = TextEditingController();
  var _category = LibraryCategory.all;

  void _openCatalog() {
    Navigator.of(context).pushNamed(
      AppRoutes.catalog,
      arguments: CatalogQuery(query: _search.text, category: _category),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrbitaColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final loans = demoLoans.where(
      (loan) =>
          _category.includes(loan.category) &&
          matchesQuery(_search.text, [loan.title, loan.author]),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Busca filtra o acervo e os empréstimos',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Buscar título, autor ou assunto',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _openCatalog(),
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
              SectionHeader(
                title: 'Meus empréstimos',
                actionLabel: 'ver acervo',
                onAction: _openCatalog,
              ),
              if (loans.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Nenhum empréstimo para esta busca.',
                    style: textTheme.bodyMedium,
                  ),
                ),
              for (final loan in loans)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            color: colors.secondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loan.title, style: textTheme.bodyLarge),
                                Text(
                                  '${loan.author} · devolver até ${loan.dueDate}',
                                  style: textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Semantics(
                            container: true,
                            label: loan.dueSoon
                                ? 'Prazo próximo de devolução: ${loan.daysRemaining} dias'
                                : 'Devolução em ${loan.daysRemaining} dias',
                            excludeSemantics: true,
                            child: StatusTag(
                              label: '${loan.daysRemaining} dias',
                              tone: loan.dueSoon
                                  ? TagTone.danger
                                  : TagTone.neutral,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
