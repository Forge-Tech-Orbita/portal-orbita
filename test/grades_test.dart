import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/features/grades/data/grade.dart';
import 'package:portal_orbita/features/grades/data/grades_mock.dart';
import 'package:portal_orbita/features/grades/presentation/grades_screen.dart';
import 'package:portal_orbita/features/grades/presentation/widgets/gpa_ring_progress.dart';

Future<void> selectFilter(WidgetTester tester, String label) async {
  final chip = find.widgetWithText(ChoiceChip, label);
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

Future<void> openGrades(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Notas'));
  await tester.pumpAndSettle();
}

Future<Finder> expandGrade(WidgetTester tester, String subject) async {
  final card = find.widgetWithText(Card, subject);
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(of: card, matching: find.text(subject)));
  await tester.pumpAndSettle();
  return card;
}

void main() {
  test('fixtures preservam as cinco notas e seus status explícitos', () {
    expect(
      demoGrades
          .map(
            (grade) => (
              grade.subject,
              grade.code,
              grade.av1,
              grade.av2,
              grade.frequency,
              grade.status,
            ),
          )
          .toList(),
      [
        (
          'Arquitetura de Software',
          'ESW-304',
          8.5,
          9.0,
          96,
          GradeStatus.completed,
        ),
        (
          'Inteligência Artificial',
          'ESW-412',
          7.0,
          8.0,
          91,
          GradeStatus.completed,
        ),
        ('Banco de Dados II', 'ESW-298', 6.5, 7.0, 88, GradeStatus.completed),
        (
          'Engenharia de Requisitos',
          'ESW-355',
          9.0,
          9.5,
          98,
          GradeStatus.completed,
        ),
        ('Cálculo Numérico', 'MAT-210', 5.5, null, 82, GradeStatus.inProgress),
      ],
    );
  });

  test('média exige AV2 e é exibida com uma casa decimal', () {
    expect(demoGrades.map((grade) => grade.average), [
      8.75,
      7.5,
      6.75,
      9.25,
      null,
    ]);
    expect(demoGrades.map((grade) => grade.average?.toStringAsFixed(1)), [
      '8.8',
      '7.5',
      '6.8',
      '9.3',
      null,
    ]);
  });

  test('AV2 zero é uma nota válida, não uma avaliação ausente', () {
    const grade = Grade(
      subject: 'Exemplo',
      code: 'TEST',
      av1: 8,
      av2: 0,
      frequency: 100,
      status: GradeStatus.completed,
    );
    expect(grade.average, 4);
  });

  testWidgets('CRA e resumo são fixos e independentes do filtro', (
    tester,
  ) async {
    await openGrades(tester);

    expect(find.text('Notas & frequência'), findsOneWidget);
    expect(find.text('Resumo demonstrativo'), findsOneWidget);
    expect(find.bySemanticsLabel('CRA demonstrativo'), findsOneWidget);
    expect(
      tester.widget<GpaRingProgress>(find.byType(GpaRingProgress)).value,
      8.7,
    );
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      closeTo(0.87, 0.00001),
    );
    for (final label in [
      'Aprovadas',
      'Cursando',
      'Pendentes',
      '18',
      '5',
      '0',
    ]) {
      expect(find.text(label), findsWidgets);
    }
    await selectFilter(tester, 'Cursando');
    expect(find.text('8.7'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  for (final (filter, codes) in [
    ('Todas', ['ESW-304', 'ESW-412', 'ESW-298', 'ESW-355', 'MAT-210']),
    ('Cursando', ['MAT-210']),
    ('Concluídas', ['ESW-304', 'ESW-412', 'ESW-298', 'ESW-355']),
  ]) {
    testWidgets('filtro $filter mostra somente as disciplinas esperadas', (
      tester,
    ) async {
      await openGrades(tester);
      await selectFilter(tester, filter);

      expect(find.byType(Card), findsNWidgets(codes.length));
      final selected = tester
          .widgetList<ChoiceChip>(find.byType(ChoiceChip))
          .where((chip) => chip.selected)
          .single;
      expect((selected.label as Text).data, filter);
      for (final grade in demoGrades) {
        expect(
          find.text(grade.code),
          codes.contains(grade.code) ? findsOneWidget : findsNothing,
        );
      }
    });
  }

  testWidgets('card abre avaliações e frequência e pode ser recolhido', (
    tester,
  ) async {
    await openGrades(tester);
    const subject = 'Arquitetura de Software';
    final card = await expandGrade(tester, subject);

    for (final text in [
      '8.8',
      'AV1',
      'AV2',
      '8.5',
      '9.0',
      'Frequência: 96% · Situação: Aprovado',
    ]) {
      expect(
        find.descendant(of: card, matching: find.text(text)),
        findsOneWidget,
      );
    }
    expect(
      tester
          .widgetList<LinearProgressIndicator>(
            find.descendant(
              of: card,
              matching: find.byType(LinearProgressIndicator),
            ),
          )
          .map((bar) => bar.value),
      [0.85, 0.9],
    );
    final title = find.descendant(of: card, matching: find.text(subject));
    await tester.ensureVisible(title);
    await tester.pumpAndSettle();
    await tester.tap(title);
    await tester.pumpAndSettle();
    expect(find.descendant(of: card, matching: find.text('AV1')), findsNothing);
  });

  testWidgets('AV2 ausente aparece como traço e não como zero', (tester) async {
    await openGrades(tester);
    await selectFilter(tester, 'Cursando');
    final card = await expandGrade(tester, 'Cálculo Numérico');

    for (final text in [
      'Cursando',
      '5.5',
      '—',
      'Frequência: 82% · Situação: Em andamento',
    ]) {
      expect(
        find.descendant(of: card, matching: find.text(text)),
        findsOneWidget,
      );
    }
    final bars = tester
        .widgetList<LinearProgressIndicator>(
          find.descendant(
            of: card,
            matching: find.byType(LinearProgressIndicator),
          ),
        )
        .toList();
    expect(bars.map((bar) => bar.value), [0.55, 0]);
    expect(find.bySemanticsLabel('AV2: Não informada'), findsOneWidget);
    expect(find.bySemanticsLabel('AV1: 5.5 de 10'), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('0.0')), findsNothing);
  });

  testWidgets(
    'Banco de Dados II mantém média 6.8 e status aprovado do legado',
    (tester) async {
      await openGrades(tester);
      final card = await expandGrade(tester, 'Banco de Dados II');

      expect(
        find.descendant(of: card, matching: find.text('6.8')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: card,
          matching: find.text('Frequência: 88% · Situação: Aprovado'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('trocar filtro fecha os detalhes anteriores', (tester) async {
    await openGrades(tester);
    await expandGrade(tester, 'Arquitetura de Software');
    expect(find.text('AV1'), findsOneWidget);
    await selectFilter(tester, 'Cursando');
    await selectFilter(tester, 'Todas');
    expect(find.text('AV1'), findsNothing);
    expect(find.byType(Card), findsNWidgets(5));
  });

  testWidgets('filtro e detalhes persistem ao trocar de aba', (tester) async {
    await openGrades(tester);
    await selectFilter(tester, 'Cursando');
    await expandGrade(tester, 'Cálculo Numérico');
    final state = tester.state(find.byType(GradesScreen));
    await tester.tap(find.text('Horário'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notas'));
    await tester.pumpAndSettle();

    expect(tester.state(find.byType(GradesScreen)), same(state));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Cursando'))
          .selected,
      isTrue,
    );
    expect(find.byType(Card), findsOneWidget);
    expect(find.text('AV2'), findsOneWidget);
  });

  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(360, 640),
  ]) {
    testWidgets('última nota pode ser expandida sem overflow em $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await openGrades(tester);
      final card = await expandGrade(tester, 'Cálculo Numérico');
      final details = find.descendant(
        of: card,
        matching: find.text('Frequência: 82% · Situação: Em andamento'),
      );
      await tester.ensureVisible(details);
      await tester.pumpAndSettle();

      expect(details.hitTestable(), findsOneWidget);
      await selectFilter(tester, 'Cursando');
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
