import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/widgets/material_tile.dart';
import 'package:portal_orbita/features/auth/presentation/login_screen.dart';
import 'package:portal_orbita/features/materials/presentation/new_material_screen.dart';
import 'package:portal_orbita/features/professor/data/professor.dart';
import 'package:portal_orbita/features/professor/data/professor_mock.dart';
import 'package:portal_orbita/features/professor/presentation/attendance_screen.dart';
import 'package:portal_orbita/features/professor/presentation/professor_shell.dart';

import 'helpers.dart';

Future<void> openProfessor(WidgetTester tester) => loginAs(tester, 'P2019042');

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('frequência arredonda e marca risco abaixo de 75%', () {
    const carla = StudentAttendance(name: 'Carla', absences: 7);
    const marina = StudentAttendance(name: 'Marina', absences: 2);
    expect(attendancePercent(carla, 24), 71);
    expect(attendancePercent(marina, 24), 92);
    expect(isAtRisk(carla, 24), isTrue);
    expect(isAtRisk(marina, 24), isFalse);
    expect(
      classAttendance['ESW-412-N']!.where((s) => isAtRisk(s, 24)),
      hasLength(3),
    );
  });

  testWidgets('início do professor mostra métricas, próxima aula e alertas', (
    tester,
  ) async {
    await openProfessor(tester);

    expect(find.byType(ProfessorShell), findsOneWidget);
    expect(find.text(professorName), findsOneWidget);
    for (final text in ['3', '12', '104', 'Seg · 19:00']) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.text('3 alunos abaixo de 75% em IA'), findsOneWidget);
    expect(find.text('Comunicado lido por 31 de 38'), findsOneWidget);
    expect(
      find.text(
        'Notas e chamada são lançadas no sistema acadêmico da instituição.',
      ),
      findsOneWidget,
    );
    for (final label in [
      'Início',
      'Turmas',
      'Materiais',
      'Frequência',
      'Avisos',
    ]) {
      expect(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('alerta de risco abre a frequência filtrada', (tester) async {
    await openProfessor(tester);
    await tapVisible(tester, find.text('3 alunos abaixo de 75% em IA'));

    expect(find.byType(AttendanceScreen), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Em risco (3)'))
          .selected,
      isTrue,
    );
    expect(find.text('Marina Duarte Costa'), findsNothing);
    expect(find.text('Carla Nunes Prado'), findsOneWidget);
    expect(find.text('Abaixo de 75%'), findsWidgets);

    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Todos'));
    expect(find.text('Marina Duarte Costa'), findsOneWidget);
    expect(find.text('2 faltas em 24 encontros'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);
  });

  testWidgets('turma abre a frequência daquela turma', (tester) async {
    await openProfessor(tester);
    await openTab(tester, 'Turmas');

    expect(find.text('Minhas turmas'), findsOneWidget);
    expect(find.text('5 materiais'), findsOneWidget);
    await tapVisible(tester, find.text('Aprendizado de Máquina'));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'ESW-430-N'))
          .selected,
      isTrue,
    );
    expect(find.text('Gabriela Souza Melo'), findsOneWidget);
  });

  testWidgets('materiais filtram por turma, incluindo material comum', (
    tester,
  ) async {
    await openProfessor(tester);
    await openTab(tester, 'Materiais');

    expect(find.byType(MaterialTile), findsNWidgets(4));
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'ESW-412-M'));
    expect(find.byType(MaterialTile), findsOneWidget);
    expect(find.text('Notas de aula · Busca heurística'), findsOneWidget);
  });

  testWidgets('novo material valida, publica e atualiza contagens', (
    tester,
  ) async {
    await openProfessor(tester);
    await tapVisible(tester, find.text('Postar material'));
    expect(find.byType(NewMaterialScreen), findsOneWidget);
    expect(find.text('Para qual turma'), findsOneWidget);

    await tapVisible(tester, find.text('Publicar material'));
    expect(find.text('Informe o título do material.'), findsOneWidget);

    await tapVisible(tester, find.text('Escolher arquivo PDF'));
    expect(find.textContaining('após a integração'), findsOneWidget);
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .removeCurrentSnackBar();
    await tester.pumpAndSettle();

    await tapVisible(
      tester,
      find.widgetWithText(ChoiceChip, 'Link recomendado'),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'Slides de busca');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'site sem esquema',
    );
    await tapVisible(tester, find.text('Publicar material'));
    expect(find.text('Use um link começando com http(s)://'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(1),
      'https://exemplo.org/slides',
    );
    await tapVisible(tester, find.text('Publicar material'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.byType(NewMaterialScreen), findsNothing);
    expect(find.text('Material publicado e alunos notificados.'), findsOne);
    expect(find.text('Slides de busca'), findsOneWidget);
    expect(find.byType(MaterialTile), findsNWidgets(5));

    await openTab(tester, 'Turmas');
    expect(find.text('6 materiais'), findsOneWidget);
    await openTab(tester, 'Início');
    expect(find.text('13'), findsOneWidget);
  });

  testWidgets('comunicado valida e entra na lista de enviados', (tester) async {
    await openProfessor(tester);
    await openTab(tester, 'Avisos');

    await tapVisible(tester, find.text('Publicar comunicado'));
    expect(
      find.text('Informe um título com ao menos 5 caracteres.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Prova adiada');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'A prova passa para a próxima semana.',
    );
    await tapVisible(tester, find.text('Publicar comunicado'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.textContaining('alunos notificados'), findsOneWidget);
    expect(find.text('Prova adiada'), findsOneWidget);
    expect(find.text('Aula de revisão na segunda'), findsOneWidget);
  });

  testWidgets('avatar encerra a sessão do professor', (tester) async {
    await openProfessor(tester);
    await tapVisible(tester, find.byTooltip('Conta'));
    await tapVisible(tester, find.text('Encerrar sessão'));
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProfessorShell, skipOffstage: false), findsNothing);
  });

  for (final size in testViewports) {
    testWidgets('abas do professor sem overflow com texto 2× em $size', (
      tester,
    ) async {
      useViewport(tester, size, textScale: 2);
      await openProfessor(tester);
      for (final (tab, lastText) in [
        (
          'Início',
          'Notas e chamada são lançadas no sistema acadêmico da instituição.',
        ),
        ('Turmas', '3 materiais'),
        ('Materiais', 'Documentação do scikit-learn'),
        ('Frequência', '7 faltas em 24 encontros'),
        ('Avisos', 'Aula de revisão na segunda'),
      ]) {
        await openTab(tester, tab);
        await tester.ensureVisible(find.text(lastText).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: tab);
      }
    });
  }
}
