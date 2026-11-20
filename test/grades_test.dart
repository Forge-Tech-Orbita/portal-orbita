import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/features/grades/data/grade.dart';
import 'package:portal_orbita/features/grades/data/grades_mock.dart';
import 'package:portal_orbita/features/grades/data/grades_summary.dart';
import 'package:portal_orbita/features/grades/presentation/grades_screen.dart';
import 'package:portal_orbita/features/grades/presentation/widgets/gpa_ring_progress.dart';

import 'helpers.dart';

const _pendingGrade = Grade(
  subject: 'Cálculo Numérico',
  code: 'MAT-210',
  firstStage: GradeStage.first(exam: 4, ted: 1.5),
  secondStage: GradeStage.second(),
  frequency: 82,
  status: GradeStatus.inProgress,
);

const _completedGrade = Grade(
  subject: 'Algoritmos',
  code: 'ESW-101',
  firstStage: GradeStage.first(exam: 7, ted: 3),
  secondStage: GradeStage.second(exam: 6, ted: 3, integratedAssessment: 1),
  frequency: 100,
  status: GradeStatus.completed,
);

Future<void> pumpGrades(
  WidgetTester tester, [
  List<Grade> grades = demoGrades,
]) => pumpScreen(tester, Scaffold(body: GradesScreen(grades: grades)));

Future<void> expandGrade(WidgetTester tester, String subject) async {
  await tapVisible(tester, find.text(subject));
}

void main() {
  test('resumo conta aprovadas, cursando e pendentes', () {
    expect(summarizeGrades(const []), (
      average: null,
      approved: 0,
      inProgress: 0,
      pending: 0,
    ));
    expect(summarizeGrades([_completedGrade, _pendingGrade]), (
      average: 10,
      approved: 1,
      inProgress: 1,
      pending: 1,
    ));
  });

  test(
    'fixtures têm as quatro disciplinas cursando com médias do protótipo',
    () {
      expect(demoGrades.map((grade) => (grade.subject, grade.code)), [
        ('Arquitetura de Software', 'ESW-304'),
        ('Inteligência Artificial', 'ESW-412'),
        ('Banco de Dados II', 'ESW-298'),
        ('Engenharia de Requisitos', 'ESW-355'),
      ]);
      expect(demoGrades.map((grade) => formatGrade(grade.average!)), [
        '8,8',
        '7,5',
        '6,75',
        '9,3',
      ]);
      expect(
        demoGrades.every((grade) => grade.status == GradeStatus.inProgress),
        isTrue,
      );
      final ai = demoGrades[1];
      expect(
        (ai.firstStage.total, ai.secondStage.total, ai.frequency),
        (7.0, 8.0, 92),
      );
    },
  );

  test('formatGrade usa vírgula e duas casas só quando necessário', () {
    expect(formatGrade(7.5), '7,5');
    expect(formatGrade(6.75), '6,75');
    expect(formatGrade(10), '10,0');
  });

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

  testWidgets('cabeçalho mostra CRA histórico e contagens', (tester) async {
    await pumpGrades(tester);

    expect(find.text('Notas & frequência'), findsOneWidget);
    expect(
      tester.widget<GpaRingProgress>(find.byType(GpaRingProgress)).value,
      historicalGpa,
    );
    expect(find.text('Aprovadas (histórico)'), findsOneWidget);
    expect(find.text('$historicalApproved'), findsOneWidget);
    expect(find.text('Pendentes'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Cursando (4)'), findsOneWidget);
    expect(find.text('6,75 · abaixo de 7'), findsOneWidget);
    expect(find.text('9,3'), findsOneWidget);
  });

  testWidgets('filtros mostram disciplinas e mensagem de vazio', (
    tester,
  ) async {
    await pumpGrades(tester, [...demoGrades, _completedGrade]);

    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Concluídas'));
    expect(find.text('Algoritmos'), findsOneWidget);
    expect(find.text('Arquitetura de Software'), findsNothing);

    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Cursando (4)'));
    expect(find.text('Algoritmos'), findsNothing);
    expect(find.text('Engenharia de Requisitos'), findsOneWidget);

    await pumpGrades(tester);
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Concluídas'));
    expect(
      find.text('Nenhuma disciplina concluída neste semestre.'),
      findsOneWidget,
    );
  });

  testWidgets('card abre AV1, AV2, média, frequência e etapas', (tester) async {
    await pumpGrades(tester);
    await expandGrade(tester, 'Inteligência Artificial');

    for (final label in ['AV1: 7,0', 'AV2: 8,0', 'Média: 7,5', 'Freq.: 92%']) {
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }
    expect(find.text('1ª etapa'), findsOneWidget);
    expect(find.text('Avaliação Integrada: 1.0 de 1'), findsOneWidget);
    expect(find.text('Frequência: 92% · Situação: Cursando'), findsOneWidget);

    await expandGrade(tester, 'Inteligência Artificial');
    expect(find.text('1ª etapa'), findsNothing);
  });

  testWidgets('etapa sem notas exibe pendências', (tester) async {
    await pumpGrades(tester, const [_pendingGrade]);
    expect(find.text('Pendente'), findsOneWidget);
    await expandGrade(tester, 'Cálculo Numérico');
    expect(find.text('Subtotal: Pendente'), findsOneWidget);
    expect(find.text('AV2: Não informada'), findsOneWidget);
    expect(find.text('Nota final: Pendente'), findsOneWidget);
  });

  testWidgets('filtro e detalhes persistem ao trocar de aba', (tester) async {
    await loginAs(tester);
    await tester.tap(find.text('Notas'));
    await tester.pumpAndSettle();
    await expandGrade(tester, 'Banco de Dados II');
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notas'));
    await tester.pumpAndSettle();
    expect(find.text('Frequência: 86% · Situação: Cursando'), findsOneWidget);
  });

  for (final size in testViewports) {
    testWidgets('última nota expandida sem overflow em $size', (tester) async {
      useViewport(tester, size, textScale: 2);
      await pumpGrades(tester);
      await expandGrade(tester, 'Engenharia de Requisitos');
      await tester.ensureVisible(
        find.text('Frequência: 92% · Situação: Cursando').last,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
