import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/theme/orbita_theme.dart';
import 'package:portal_orbita/features/library/data/loans_mock.dart';

Future<void> openLibrary(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  await tester.ensureVisible(find.text('ENTRAR NO PORTAL'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
  final shortcut = find.widgetWithText(OutlinedButton, 'Biblioteca');
  await tester.ensureVisible(shortcut);
  await tester.pumpAndSettle();
  await tester.tap(shortcut);
  await tester.pumpAndSettle();
}

void main() {
  test(
    'fixtures preservam os três empréstimos sem inferir datas ou acervo',
    () {
      expect(
        demoLoans
            .map(
              (loan) =>
                  (loan.title, loan.author, loan.daysRemaining, loan.dueSoon),
            )
            .toList(),
        [
          ('Estruturas de Dados e Algoritmos', 'T. Cormen', 2, true),
          ('Arquitetura Limpa', 'R. C. Martin', 12, false),
          ('Redes Neurais e Deep Learning', 'I. Goodfellow', 18, false),
        ],
      );
    },
  );

  testWidgets(
    'biblioteca mostra busca demonstrativa, categorias e três empréstimos',
    (tester) async {
      await openLibrary(tester);
      expect(find.text('Busca e categorias demonstrativas'), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration!.labelText, 'Busca demonstrativa');
      expect(field.decoration!.hintText, 'Buscar título, autor ou ISBN...');
      expect(find.byType(Chip), findsNWidgets(5));
      for (final category in [
        'Todos',
        'Exatas',
        'Computação',
        'Humanas',
        'Periódicos',
      ]) {
        final chip = find.widgetWithText(Chip, category);
        await tester.ensureVisible(chip);
        await tester.pumpAndSettle();
        expect(chip.hitTestable(), findsOneWidget);
      }
      expect(find.byType(ChoiceChip), findsNothing);
      expect(find.byType(FilterChip), findsNothing);
      expect(find.byType(Card), findsNWidgets(3));
      for (final loan in demoLoans) {
        final card = find.widgetWithText(Card, loan.title);
        await tester.ensureVisible(card);
        await tester.pumpAndSettle();
        expect(
          find.descendant(of: card, matching: find.text(loan.author)),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: card,
            matching: find.text('${loan.daysRemaining} dias'),
          ),
          findsOneWidget,
        );
      }
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    },
  );

  testWidgets('prazo de dois dias usa alerta visual e descrição acessível', (
    tester,
  ) async {
    await openLibrary(tester);
    final warning = find.text('2 dias');
    expect(tester.widget<Text>(warning).style!.color, OrbitaTheme.alert);
    expect(
      tester.getSemantics(warning).getSemanticsData().label,
      contains('Prazo próximo de devolução: 2 dias'),
    );
    for (final days in [12, 18]) {
      final due = find.text('$days dias');
      await tester.ensureVisible(due);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(due).style!.color, OrbitaTheme.text);
      expect(
        tester.getSemantics(due).getSemanticsData().label,
        contains('Devolução em $days dias'),
      );
    }
  });

  testWidgets('digitar e concluir a busca não filtra nem inventa resultados', (
    tester,
  ) async {
    await openLibrary(tester);
    await tester.enterText(find.byType(TextField), 'título inexistente');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNWidgets(3));
    for (final loan in demoLoans) {
      expect(find.text(loan.title), findsOneWidget);
    }
    expect(find.text('Busca e categorias demonstrativas'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'campo e empréstimos permanecem roláveis em 360 × 640 com teclado',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      await openLibrary(tester);
      await tester.showKeyboard(find.byType(TextField));
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'Consulta demonstrativa com título longo',
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('18 dias'));
      await tester.pumpAndSettle();

      expect(find.text('18 dias').hitTestable(), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(360, 640),
  ]) {
    testWidgets(
      'categorias e último empréstimo alcançáveis sem overflow em $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await openLibrary(tester);
        final lastCategory = find.widgetWithText(Chip, 'Periódicos');
        await tester.ensureVisible(lastCategory);
        await tester.pumpAndSettle();
        expect(lastCategory.hitTestable(), findsOneWidget);
        await tester.ensureVisible(find.text('18 dias'));
        await tester.pumpAndSettle();
        expect(find.text('18 dias').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'texto ampliado mantém títulos e prazos acessíveis sem overflow',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openLibrary(tester);

      for (final loan in demoLoans) {
        await tester.ensureVisible(find.text(loan.title));
        await tester.pumpAndSettle();
        expect(find.text(loan.title).hitTestable(), findsOneWidget);
        await tester.ensureVisible(find.text('${loan.daysRemaining} dias'));
        await tester.pumpAndSettle();
        expect(
          find.text('${loan.daysRemaining} dias').hitTestable(),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    },
  );
}
