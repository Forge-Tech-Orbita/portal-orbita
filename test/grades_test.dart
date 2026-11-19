import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/features/grades/data/grade.dart';
import 'package:portal_orbita/features/grades/data/grades_mock.dart';
import 'package:portal_orbita/features/grades/data/grades_summary.dart';
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
  test('resumo sem disciplinas tem média indisponível e totais zerados', () {
    expect(summarizeGrades(const []), (
      average: null,
      approved: 0,
      inProgress: 0,
    ));
  });

  test('resumo conta disciplinas sem média pela situação', () {
    final completed = demoGrades.first;
    final inProgress = demoGrades.last;

    expect(summarizeGrades([inProgress]), (
      average: null,
      approved: 0,
      inProgress: 1,
    ));
    expect(summarizeGrades([completed, inProgress]), (
      average: completed.average,
      approved: 1,
      inProgress: 1,
    ));
  });

  test('fixtures preservam as cinco notas e seus status explícitos', () {
    expect(
      demoGrades
          .map(
            (grade) => (
              grade.subject,
              grade.code,
              grade.firstStage.total,
              grade.secondStage.total,
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

  test(
    'média exige as duas etapas completas e é exibida com uma casa decimal',
    () {
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
    },
  );

  test('zero é uma nota lançada e entra na média', () {
    const grade = Grade(
      subject: 'Exemplo',
      code: 'TEST',
      firstStage: GradeStage.first(exam: 6, ted: 2),
      secondStage: GradeStage.second(exam: 0, ted: 0, integratedAssessment: 0),
      frequency: 100,
      status: GradeStatus.completed,
    );
    expect(grade.average, 4);
  });

  test('AV1 soma prova de sete e TED de três sem integrada', () {
    const stage = GradeStage.first(exam: 7, ted: 3);
    expect(stage.examMax, 7);
    expect(stage.total, 10);
    expect(stage.integratedAssessment, isNull);
    expect(const GradeStage.first(exam: 7).total, isNull);
  });

  test('AV2 exige integrada para completar dez pontos', () {
    expect(
      const GradeStage.second(exam: 6, ted: 3, integratedAssessment: 1).total,
      10,
    );
    expect(const GradeStage.second(exam: 6, ted: 3).total, isNull);
  });

  test('etapa com TED pendente mantém o subtotal indisponível', () {
    const stage = GradeStage.second(exam: 6, integratedAssessment: 1);
    expect(stage.total, isNull);
  });

  testWidgets('resumo calculado do semestre independe do filtro', (
    tester,
  ) async {
    await openGrades(tester);

    expect(find.text('Notas & frequência'), findsOneWidget);
    expect(find.text('Resumo demonstrativo'), findsOneWidget);
    expect(find.bySemanticsLabel('Média do semestre'), findsOneWidget);
    expect(
      tester.widget<GpaRingProgress>(find.byType(GpaRingProgress)).value,
      8.0625,
    );
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      closeTo(0.80625, 0.00001),
    );
    for (final label in ['Aprovadas', 'Cursando', '4', '1']) {
      expect(find.text(label), findsWidgets);
    }
    await selectFilter(tester, 'Cursando');
    expect(find.text('8.1'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('filtro vazio mostra mensagem e mantém o resumo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GradesScreen(grades: [demoGrades.first])),
      ),
    );

    final summary = find.byType(GpaRingProgress);
    final expectedAverage = demoGrades.first.average;
    expect(tester.widget<GpaRingProgress>(summary).value, expectedAverage);
    expect(find.byType(Card), findsOneWidget);

    await selectFilter(tester, 'Cursando');
    expect(
      find.text('Nenhuma disciplina cursando neste semestre.'),
      findsOneWidget,
    );
    expect(find.byType(Card), findsNothing);
    expect(tester.widget<GpaRingProgress>(summary).value, expectedAverage);

    await selectFilter(tester, 'Todas');
    expect(
      find.text('Nenhuma disciplina cursando neste semestre.'),
      findsNothing,
    );
    expect(find.byType(Card), findsOneWidget);
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
      'AV1: 6.0 de 7',
      '1ª etapa',
      '2ª etapa',
      'Nota final: 8.8 de 10',
      'AV2: 5.5 de 6',
      'Subtotal: 8.5 de 10',
      'Subtotal: 9.0 de 10',
      'Frequência: 96% · Situação: Aprovado',
    ]) {
      expect(
        find.descendant(of: card, matching: find.text(text)),
        findsOneWidget,
      );
    }
    expect(
      find.bySemanticsLabel('Avaliação Integrada: 1.0 de 1'),
      findsOneWidget,
    );
    expect(
      tester
          .widgetList<LinearProgressIndicator>(
            find.descendant(
              of: card,
              matching: find.byType(LinearProgressIndicator),
            ),
          )
          .map((bar) => bar.value),
      [6 / 7, 2.5 / 3, 5.5 / 6, 2.5 / 3, 1],
    );
    final title = find.descendant(of: card, matching: find.text(subject));
    await tester.ensureVisible(title);
    await tester.pumpAndSettle();
    await tester.tap(title);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: card, matching: find.text('1ª etapa')),
      findsNothing,
    );
  });

  testWidgets('etapa sem notas exibe pendências', (tester) async {
    await openGrades(tester);
    await selectFilter(tester, 'Cursando');
    final card = await expandGrade(tester, 'Cálculo Numérico');

    for (final text in [
      'Cursando',
      'Subtotal: 5.5 de 10',
      'AV2: Não informada',
      'TED: Não informada',
      'Avaliação Integrada: Não informada',
      'Nota final: Pendente',
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
    expect(bars.map((bar) => bar.value), [4 / 7, 1.5 / 3]);
    expect(find.bySemanticsLabel('AV2: Não informada'), findsOneWidget);
    expect(find.bySemanticsLabel('AV1: 4.0 de 7'), findsOneWidget);
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
    expect(find.text('1ª etapa'), findsOneWidget);
    await selectFilter(tester, 'Cursando');
    await selectFilter(tester, 'Todas');
    expect(find.text('1ª etapa'), findsNothing);
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
    expect(find.text('2ª etapa'), findsOneWidget);
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
