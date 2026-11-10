import 'package:flutter/material.dart';

import '../../../core/theme/orbita_theme.dart';
import '../data/loans_mock.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Busca e categorias demonstrativas',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              const TextField(
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Busca demonstrativa',
                  hintText: 'Buscar título, autor ou ISBN...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8,
                  children: [
                    for (final category in const [
                      'Todos',
                      'Exatas',
                      'Computação',
                      'Humanas',
                      'Periódicos',
                    ])
                      Chip(label: Text(category)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Meus empréstimos', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final loan in demoLoans)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: OrbitaTheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.menu_book_outlined,
                          size: 32,
                          color: OrbitaTheme.terracotta,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loan.title, style: textTheme.titleSmall),
                              Text(loan.author),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Semantics(
                          label: loan.dueSoon
                              ? 'Prazo próximo de devolução: ${loan.daysRemaining} dias'
                              : 'Devolução em ${loan.daysRemaining} dias',
                          excludeSemantics: true,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (loan.dueSoon
                                          ? OrbitaTheme.alert
                                          : OrbitaTheme.primary)
                                      .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${loan.daysRemaining} dias',
                              style: textTheme.labelMedium?.copyWith(
                                color: loan.dueSoon
                                    ? OrbitaTheme.alert
                                    : OrbitaTheme.text,
                              ),
                            ),
                          ),
                        ),
                      ],
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
