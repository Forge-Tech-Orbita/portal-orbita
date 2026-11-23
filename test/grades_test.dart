import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/models/student_profile.dart';
import 'package:portal_orbita/features/auth/data/academic_session.dart';
import 'package:portal_orbita/features/grades/data/grade.dart';
import 'package:portal_orbita/features/grades/data/grades_summary.dart';
import 'package:portal_orbita/features/grades/presentation/grades_screen.dart';

import 'helpers.dart';
import 'fake_grades_repository.dart';
import 'grades_fixtures.dart';

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
  status: GradeStatus.approved,
);

Future<void> pumpGrades(
  WidgetTester tester, [
  List<Grade> grades = demoGrades,
]) async {
  await pumpScreen(
    tester,
    Scaffold(
      body: GradesScreen(
        repository: FakeGradesRepository()..grades = grades,
        profile: gradesProfile,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> expandGrade(WidgetTester tester, String subject) async {
  await tapVisible(tester, find.text(subject));
}

void main() {
  testWidgets(
    'carregamento, vazio, erro, retry e atualização não usam fixtures',
    (tester) async {
      final pending = Completer<List<Grade>>();
      final repository = FakeGradesRepository()..pending = pending.future;
      await pumpScreen(
        tester,
        Scaffold(
          body: GradesScreen(repository: repository, profile: gradesProfile),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Arquitetura de Software'), findsNothing);
      pending.complete([]);
      await tester.pumpAndSettle();
      expect(
        find.text('Nenhuma nota cadastrada para este semestre.'),
        findsOneWidget,
      );
      expect(find.text('Aprovadas no semestre'), findsNothing);

      repository.pending = null;
      repository.error = StateError('permission-denied: informação privada');
      await tapVisible(tester, find.text('Atualizar notas'));
      expect(
        find.textContaining('Não foi possível carregar as notas'),
        findsOneWidget,
      );
      expect(find.textContaining('informação privada'), findsNothing);
      expect(
        find.text('Nenhuma nota cadastrada para este semestre.'),
        findsNothing,
      );

      repository.error = const FormatException('documento privado');
      await tapVisible(tester, find.text('Tentar novamente'));
      expect(
        find.textContaining('Os dados das notas estão indisponíveis'),
        findsOneWidget,
      );
      expect(find.textContaining('documento privado'), findsNothing);

      repository.error = null;
      repository.grades = [_pendingGrade];
      await tapVisible(tester, find.text('Tentar novamente'));
      expect(find.text('Cálculo Numérico'), findsOneWidget);
      expect(find.text('Arquitetura de Software'), findsNothing);
      final refresh = Completer<List<Grade>>();
      repository.pending = refresh.future;
      await tester.tap(find.text('Atualizar notas'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cálculo Numérico'), findsNothing);
      refresh.complete([_completedGrade]);
      await tester.pumpAndSettle();
      expect(find.text('Algoritmos'), findsOneWidget);
      expect(repository.calls, hasLength(5));
    },
  );

  testWidgets('ausência de perfil/curso não consulta notas', (tester) async {
    final repository = FakeGradesRepository();
    for (final profile in <StudentProfile?>[
      null,
      const StudentProfile(
        uid: 'student-a',
        name: 'Aluno',
        registration: '202600001',
        institutionId: 'inst-demo',
        courseId: null,
        semester: '2026-2',
        period: 4,
      ),
    ]) {
      await pumpScreen(
        tester,
        Scaffold(
          body: GradesScreen(repository: repository, profile: profile),
        ),
      );
      expect(repository.calls, isEmpty);
      expect(find.textContaining('Entre com um perfil válido'), findsOneWidget);
      expect(find.text('Arquitetura de Software'), findsNothing);
    }
  });

  testWidgets('mudança de semestre/curso descarta resposta atrasada', (
    tester,
  ) async {
    final old = Completer<List<Grade>>();
    final repository = FakeGradesRepository()..pending = old.future;
    await pumpScreen(
      tester,
      Scaffold(
        body: GradesScreen(repository: repository, profile: gradesProfile),
      ),
    );
    repository.pending = null;
    repository.grades = [_completedGrade];
    const next = StudentProfile(
      uid: 'student-a',
      name: 'Aluno',
      registration: '202600001',
      institutionId: 'inst-demo',
      courseId: 'adm',
      semester: '2027-1',
      period: 5,
    );
    await pumpScreen(
      tester,
      Scaffold(
        body: GradesScreen(repository: repository, profile: next),
      ),
    );
    await tester.pumpAndSettle();
    old.complete([_pendingGrade]);
    await tester.pumpAndSettle();
    expect(repository.calls.last.semester, '2027-1');
    expect(repository.calls.last.courseId, 'adm');
    expect(find.text('Algoritmos'), findsOneWidget);
    expect(find.text('Cálculo Numérico'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('novo semestre limpa expansão e novo curso limpa filtro', (
    tester,
  ) async {
    final repository = FakeGradesRepository()..grades = [demoGrades.first];
    Future<void> show(StudentProfile profile) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: GradesScreen(repository: repository, profile: profile),
        ),
      );
      await tester.pumpAndSettle();
    }

    await show(gradesProfile);
    await expandGrade(tester, demoGrades.first.subject);
    expect(find.text('1ª etapa'), findsOneWidget);
    const nextSemester = StudentProfile(
      uid: 'student-a',
      name: 'Aluno',
      registration: '202600001',
      institutionId: 'inst-demo',
      courseId: 'si',
      semester: '2027-1',
      period: 5,
    );
    await show(nextSemester);
    expect(find.text('1ª etapa'), findsNothing);
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Concluídas'));
    expect(
      find.text('Nenhuma disciplina concluída neste semestre.'),
      findsOneWidget,
    );
    const nextCourse = StudentProfile(
      uid: 'student-a',
      name: 'Aluno',
      registration: '202600001',
      institutionId: 'inst-demo',
      courseId: 'adm',
      semester: '2027-1',
      period: 5,
    );
    await show(nextCourse);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Todas'))
          .selected,
      isTrue,
    );
    expect(find.text(demoGrades.first.subject), findsOneWidget);
    expect(
      repository.calls.map((profile) => (profile.semester, profile.courseId)),
      [('2026-2', 'si'), ('2027-1', 'si'), ('2027-1', 'adm')],
    );
  });

  testWidgets(
    'logout e outra conta isolam notas e respostas da árvore descartada',
    (tester) async {
      final old = Completer<List<Grade>>();
      final repository = FakeGradesRepository()..pending = old.future;
      final auth = await pumpTestApp(tester, gradesRepository: repository);
      await auth.signIn('inst-demo', auth.profile.registration, 'test-only');
      await tester.pump();
      await tester.pump();
      final context = tester.element(
        find.byType(GradesScreen, skipOffstage: false),
      );
      final session = AcademicSessionScope.maybeOf(context)!;
      await session.signOut();
      await tester.pumpAndSettle();
      repository.pending = null;
      repository.grades = [_completedGrade];
      auth.profile = const StudentProfile(
        uid: 'student-b',
        name: 'Outra pessoa',
        registration: '202600002',
        institutionId: 'inst-demo',
        courseId: 'adm',
        semester: '2026-2',
        period: 4,
      );
      await session.signIn('inst-demo', auth.profile.registration, 'test-only');
      await tester.pumpAndSettle();
      old.complete([_pendingGrade]);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notas'));
      await tester.pumpAndSettle();
      expect(repository.calls.map((profile) => profile.uid), [
        'student-a',
        'student-b',
      ]);
      expect(find.text('Algoritmos'), findsOneWidget);
      expect(find.text('Cálculo Numérico'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

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
      status: GradeStatus.approved,
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

  testWidgets('cabeçalho mostra semestre e contagens sem histórico inventado', (
    tester,
  ) async {
    await pumpGrades(tester);

    expect(find.text('Notas & frequência'), findsOneWidget);
    expect(find.textContaining('Semestre 2026-2'), findsOneWidget);
    expect(find.textContaining('CRA'), findsNothing);
    expect(find.text('Aprovadas (histórico)'), findsNothing);
    expect(find.text('Aprovadas no semestre'), findsOneWidget);
    expect(
      find.descendant(
        of: find
            .ancestor(
              of: find.text('Aprovadas no semestre'),
              matching: find.byType(Row),
            )
            .first,
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
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

  testWidgets('concluídas incluem disciplinas concluídas e reprovadas', (
    tester,
  ) async {
    const grades = [
      Grade(
        subject: 'Resultado não informado',
        code: 'TEST-1',
        firstStage: GradeStage.first(exam: 7, ted: 3),
        secondStage: GradeStage.second(
          exam: 6,
          ted: 3,
          integratedAssessment: 1,
        ),
        frequency: 100,
        status: GradeStatus.completed,
      ),
      Grade(
        subject: 'Disciplina reprovada',
        code: 'TEST-2',
        firstStage: GradeStage.first(exam: 0, ted: 0),
        secondStage: GradeStage.second(
          exam: 0,
          ted: 0,
          integratedAssessment: 0,
        ),
        frequency: 100,
        status: GradeStatus.failed,
      ),
    ];
    expect(summarizeGrades(grades), (
      average: 5.0,
      approved: 0,
      inProgress: 0,
      pending: 0,
    ));

    await pumpGrades(tester, grades);
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Concluídas'));

    expect(find.text('Resultado não informado'), findsOneWidget);
    expect(find.text('Disciplina reprovada'), findsOneWidget);
    expect(find.text('Concluído'), findsOneWidget);
    expect(find.text('Reprovado'), findsOneWidget);
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
    expect(find.text('Subtotal: 5.5 de 10'), findsOneWidget);
    expect(
      find.text(
        'Subtotal pendente. Falta lançar: AV2, TED, Avaliação Integrada.',
      ),
      findsOneWidget,
    );
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
    testWidgets(
      'notas na casca sem banner de apresentação e texto 2× em $size',
      (tester) async {
        useViewport(tester, size, textScale: 2);
        await loginAs(tester);
        await tester.tap(find.text('Notas'));
        await tester.pumpAndSettle();
        await expandGrade(tester, 'Engenharia de Requisitos');
        await tester.ensureVisible(
          find.text('Frequência: 92% · Situação: Cursando'),
        );
        await tester.pumpAndSettle();
        expect(find.text('Ambiente de apresentação'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
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
