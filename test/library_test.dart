import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/features/library/data/loan.dart';
import 'package:portal_orbita/features/library/data/loans_mock.dart';
import 'package:portal_orbita/features/library/presentation/catalog_screen.dart';
import 'package:portal_orbita/features/library/presentation/library_screen.dart';

import 'helpers.dart';

void main() {
  test('busca ignora caixa e aceita consulta vazia', () {
    expect(matchesQuery('', ['x']), isTrue);
    expect(matchesQuery('REDES', ['Redes de Computadores']), isTrue);
    expect(matchesQuery('cálculo', ['Redes']), isFalse);
    expect(LibraryCategory.all.includes(LibraryCategory.exact), isTrue);
    expect(LibraryCategory.exact.includes(LibraryCategory.computing), isFalse);
  });

  test('busca ignora acentos em maiúsculas e minúsculas', () {
    expect(matchesQuery('calculo', ['Cálculo · Volume 1']), isTrue);
    expect(matchesQuery('CÁLCULO', ['calculo']), isTrue);
    expect(matchesQuery('jose', ['José']), isTrue);
    expect(matchesQuery('JOSÉ', ['jose']), isTrue);
    expect(matchesQuery('redes', ['Redes de Computadores']), isTrue);
    expect(matchesQuery('computação', ['Computacao']), isTrue);
  });

  testWidgets('biblioteca mostra três empréstimos com prazo de devolução', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpScreen(tester, const LibraryScreen());

    expect(find.text('Buscar título, autor ou assunto'), findsOneWidget);
    for (final loan in demoLoans) {
      expect(find.text(loan.title), findsOneWidget);
      expect(
        find.text('${loan.author} · devolver até ${loan.dueDate}'),
        findsOneWidget,
      );
    }
    expect(
      find.bySemanticsLabel('Prazo próximo de devolução: 2 dias'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('busca e categoria filtram os empréstimos', (tester) async {
    await pumpScreen(tester, const LibraryScreen());

    await tester.enterText(find.byType(TextField), 'martin');
    await tester.pumpAndSettle();
    expect(find.text('Arquitetura Limpa'), findsOneWidget);
    expect(find.text('Redes Neurais e Deep Learning'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Exatas'));
    expect(find.text('Nenhum empréstimo para esta busca.'), findsOneWidget);
  });

  testWidgets('busca no acervo ignora acentos na pesquisa', (tester) async {
    await pumpScreen(
      tester,
      const CatalogScreen(
        initial: CatalogQuery(query: 'calculo', category: LibraryCategory.all),
      ),
    );
    expect(find.text('Cálculo · Volume 1'), findsOneWidget);
    expect(find.text('J. Stewart · 8ª ed.'), findsOneWidget);
  });

  testWidgets('empréstimos e acervo respondem igual à mesma consulta', (
    tester,
  ) async {
    const neural = 'Redes Neurais e Deep Learning';
    const algorithms = 'Estruturas de Dados e Algoritmos';
    const cases = <(String, bool, bool)>[
      ('GOODFELLOW', true, false),
      ('cormen', false, true),
      ('ESTRUTURAS', false, true),
      ('neurais', true, false),
      ('inexistente', false, false),
    ];

    for (final (query, showsNeural, showsAlgorithms) in cases) {
      await pumpScreen(tester, const LibraryScreen());
      await tester.enterText(find.byType(TextField), query);
      await tester.pumpAndSettle();
      final loansNeural = find.text(neural).evaluate().isNotEmpty;
      final loansAlgorithms = find.text(algorithms).evaluate().isNotEmpty;

      await pumpScreen(
        tester,
        CatalogScreen(
          initial: CatalogQuery(query: query, category: LibraryCategory.all),
        ),
      );
      final catalogNeural = find.text(neural).evaluate().isNotEmpty;
      final catalogAlgorithms = find.text(algorithms).evaluate().isNotEmpty;

      expect(loansNeural, showsNeural, reason: 'empréstimos: $query');
      expect(catalogNeural, showsNeural, reason: 'acervo: $query');
      expect(loansAlgorithms, showsAlgorithms, reason: 'empréstimos: $query');
      expect(catalogAlgorithms, showsAlgorithms, reason: 'acervo: $query');
    }
  });

  testWidgets('concluir a busca abre o acervo com a consulta', (tester) async {
    await loginAs(tester);
    await openFromMore(tester, 'Biblioteca');
    await tester.enterText(find.byType(TextField), 'redes');
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Computação'));
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.byType(CatalogScreen), findsOneWidget);
    expect(
      find.text('4 resultados para "redes" em Computação'),
      findsOneWidget,
    );
  });

  testWidgets('acervo reserva disponível e entra na fila de emprestado', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const CatalogScreen(
        initial: CatalogQuery(
          query: 'redes',
          category: LibraryCategory.computing,
        ),
      ),
    );
    expect(find.text('Reservar'), findsNWidgets(3));
    expect(find.text('Entrar na fila'), findsOneWidget);

    await tapVisible(tester, find.text('Reservar').first);
    expect(find.text('Reservado'), findsOneWidget);
    expect(find.text('Reservar'), findsNWidgets(2));

    await tapVisible(tester, find.text('Entrar na fila'));
    expect(find.text('Na fila'), findsOneWidget);
    expect(find.textContaining('entrou na fila'), findsOneWidget);
  });

  testWidgets('ver acervo sem consulta lista todo o acervo', (tester) async {
    await loginAs(tester);
    await openFromMore(tester, 'Biblioteca');
    await tapVisible(tester, find.text('ver acervo'));
    expect(find.text('${demoCatalog.length} resultados no acervo'), findsOne);
  });

  testWidgets(
    'busca sem resultado no acervo mostra mensagem amigavel e acao limpar busca',
    (tester) async {
      await pumpScreen(
        tester,
        const CatalogScreen(
          initial: CatalogQuery(
            query: 'termo-inexistente',
            category: LibraryCategory.all,
          ),
        ),
      );

      expect(
        find.text(
          'Nenhum livro encontrado para "termo-inexistente" no acervo.',
        ),
        findsOneWidget,
      );
      final clearButton = find.widgetWithText(OutlinedButton, 'Limpar busca');
      expect(clearButton, findsOneWidget);

      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNWidgets(demoCatalog.length));
      expect(find.text('termo-inexistente'), findsNothing);
    },
  );

  testWidgets(
    'limpar busca preserva a categoria selecionada e exibe mensagem com categoria ativa',
    (tester) async {
      await pumpScreen(
        tester,
        const CatalogScreen(
          initial: CatalogQuery(
            query: 'inexistente',
            category: LibraryCategory.computing,
          ),
        ),
      );

      expect(
        find.text(
          'Nenhum livro encontrado para "inexistente" na categoria Computação.',
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Computação'))
            .selected,
        isTrue,
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Limpar busca'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Computação'))
            .selected,
        isTrue,
      );
      expect(find.textContaining('em Computação'), findsOneWidget);
      expect(find.text('Redes de Computadores'), findsOneWidget);
    },
  );

  for (final size in testViewports) {
    testWidgets('telas da biblioteca sem overflow em $size', (tester) async {
      useViewport(tester, size, textScale: 2);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await pumpScreen(tester, const LibraryScreen());
      await tester.ensureVisible(find.text('18 dias'));
      await tester.pumpAndSettle();
      await pumpScreen(tester, const CatalogScreen());
      await tester.ensureVisible(find.text(demoCatalog.last.title));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'estado vazio do acervo sem overflow em tela estreita com texto 2x',
    (tester) async {
      useViewport(tester, const Size(360, 640), textScale: 2);
      await pumpScreen(
        tester,
        const CatalogScreen(
          initial: CatalogQuery(
            query: 'Termo Muito Longo Para Busca No Acervo Que Ocupa Varias Linhas',
            category: LibraryCategory.computing,
          ),
        ),
      );
      await tester.ensureVisible(
        find.widgetWithText(OutlinedButton, 'Limpar busca'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
