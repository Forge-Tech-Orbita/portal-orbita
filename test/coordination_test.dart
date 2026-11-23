import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/widgets/material_tile.dart';
import 'package:portal_orbita/features/auth/presentation/login_screen.dart';
import 'package:portal_orbita/features/coordination/data/coordination.dart';
import 'package:portal_orbita/features/coordination/data/coordination_mock.dart';
import 'package:portal_orbita/features/coordination/presentation/coordination_publish_screen.dart';
import 'package:portal_orbita/features/coordination/presentation/coordination_shell.dart';
import 'package:portal_orbita/features/materials/presentation/new_material_screen.dart';

import 'helpers.dart';

Future<void> openCoordination(WidgetTester tester) =>
    loginAs(tester, 'C2015007');

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
  test('turma em risco tem média abaixo de 7 ou frequência abaixo de 85%', () {
    expect(courseClasses.where((c) => c.atRisk).map((c) => c.code), [
      'ESW-298-N',
    ]);
    expect(formatAverage(6.6), '6,6');
  });

  test('data e horário do evento são validados', () {
    expect(validateEventDate('24/11/2026'), isNull);
    expect(validateEventDate('31/02/2026'), 'Data inválida.');
    expect(validateEventDate('2026-11-24'), 'Use o formato dd/mm/aaaa.');
    expect(validateEventTime('19:00'), isNull);
    expect(validateEventTime('25:00'), 'Use hh:mm.');
  });

  testWidgets('painel mostra indicadores agregados e pendências', (
    tester,
  ) async {
    await openCoordination(tester);

    expect(find.byType(CoordinationShell), findsOneWidget);
    expect(find.text(coordinatorName), findsOneWidget);
    for (final text in ['24', '7,9', '89%', 'Alunos em risco']) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.text('Semana de Tecnologia em 5 dias'), findsOneWidget);
    expect(
      find.text('Indicadores agregados · sem dados pessoais nesta tela'),
      findsOneWidget,
    );
  });

  testWidgets('pendência de frequência abre turmas em risco', (tester) async {
    await openCoordination(tester);
    await tapVisible(
      tester,
      find.text('12 alunos com frequência abaixo de 75%'),
    );

    expect(find.text('Turmas do curso'), findsOneWidget);
    expect(find.text('Banco de Dados II'), findsOneWidget);
    expect(find.text('Arquitetura de Software'), findsNothing);

    await tapVisible(tester, find.widgetWithText(ChoiceChip, '6º período'));
    expect(find.text('Banco de Dados II'), findsNothing);
    expect(find.text('Média 8,1'), findsOneWidget);
  });

  testWidgets('materiais filtram por público e aceitam novo material', (
    tester,
  ) async {
    await openCoordination(tester);
    await openTab(tester, 'Materiais');
    expect(find.byType(MaterialTile), findsNWidgets(4));
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Calouros'));
    expect(find.byType(MaterialTile), findsOneWidget);

    await tapVisible(tester, find.text('Novo material'));
    expect(find.byType(NewMaterialScreen), findsOneWidget);
    expect(find.text('Para quem'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Calendário 2027');
    await tapVisible(tester, find.text('Publicar material'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Material publicado.'), findsOneWidget);
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Curso inteiro'));
    expect(find.text('Calendário 2027'), findsOneWidget);
  });

  testWidgets('publicar evento valida campos e entra nos publicados', (
    tester,
  ) async {
    await openCoordination(tester);
    await tapVisible(tester, find.text('Publicar evento'));
    expect(find.text('Eventos e comunicados'), findsOneWidget);

    await tapVisible(tester, find.text('Publicar no mural'));
    expect(find.text('Use o formato dd/mm/aaaa.'), findsOneWidget);
    expect(find.text('Informe o local.'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Feira de estágios');
    await tester.enterText(fields.at(1), '02/12/2026');
    await tester.enterText(fields.at(2), '18:30');
    await tester.enterText(fields.at(3), 'Hall do Bloco A');
    await tester.enterText(fields.at(4), 'Empresas parceiras e vagas abertas.');
    await tapVisible(tester, find.text('Publicar no mural'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Evento publicado no mural.'), findsOneWidget);
    expect(find.text('Feira de estágios'), findsOneWidget);
  });

  testWidgets('comunicado oculta campos de evento', (tester) async {
    await openCoordination(tester);
    await openTab(tester, 'Publicar');
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Comunicado'));
    expect(find.text('Data'), findsNothing);
    expect(find.text('Pedir confirmação de presença'), findsNothing);
  });

  testWidgets('botão de sair encerra a sessão da coordenação', (tester) async {
    await openCoordination(tester);
    await tester.tap(find.byTooltip('Encerrar sessão'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  test('público da coordenação inclui o curso inteiro', () {
    expect(coordinationAudiences.first.audiences, ['Curso inteiro']);
    expect(PostKind.event.label, 'Evento');
  });

  for (final size in testViewports) {
    testWidgets('abas da coordenação sem overflow com texto 2× em $size', (
      tester,
    ) async {
      useViewport(tester, size, textScale: 2);
      await openCoordination(tester);
      for (final (tab, lastText) in [
        ('Painel', 'Indicadores agregados · sem dados pessoais nesta tela'),
        ('Turmas', 'Engenharia de Requisitos'),
        ('Materiais', 'Trilha de estudos para iniciantes'),
        ('Publicar', 'Matrícula 2027.1'),
      ]) {
        await openTab(tester, tab);
        await tester.ensureVisible(find.text(lastText).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: tab);
      }
    });
  }
}
