import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/theme/orbita_theme.dart';
import 'package:portal_orbita/features/schedule/data/schedule.dart';
import 'package:portal_orbita/features/schedule/data/schedule_mock.dart';
import 'package:portal_orbita/features/schedule/presentation/schedule_screen.dart';

Future<void> selectDay(WidgetTester tester, ScheduleDay day) async {
  final chip = find.widgetWithText(ChoiceChip, day.abbreviation);
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

Future<void> openSchedule(WidgetTester tester, ScheduleDay day) async {
  await tester.pumpWidget(const MainApp());
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Horário'));
  await tester.pumpAndSettle();
  await selectDay(tester, day);
}

void main() {
  test(
    'data seleciona dia da semana e domingo preserva fallback para sábado',
    () {
      for (var index = 0; index < ScheduleDay.values.length; index++) {
        expect(
          ScheduleDay.forDate(DateTime(2026, 11, 9 + index)),
          ScheduleDay.values[index],
        );
      }
      expect(ScheduleDay.forDate(DateTime(2026, 11, 15)), ScheduleDay.saturday);
    },
  );

  test(
    'fixture preserva oito ocorrências e os dados das cinco aulas do legado',
    () {
      expect(demoSchedule.keys, ScheduleDay.values);
      expect(demoSchedule.values.map((lessons) => lessons.length), [
        2,
        1,
        2,
        2,
        1,
        0,
      ]);
      expect(
        demoSchedule.values
            .expand((lessons) => lessons)
            .map(
              (lesson) => (
                lesson.time,
                lesson.subject,
                lesson.room,
                lesson.professor,
                lesson.color,
              ),
            )
            .toSet(),
        {
          (
            '19:00',
            'Inteligência Artificial',
            'Sala 304 · Bloco C',
            'Prof. R. Nakamura',
            OrbitaTheme.primary,
          ),
          (
            '21:00',
            'Banco de Dados II',
            'Lab 05 · Bloco B',
            'Prof.ª L. Andrade',
            OrbitaTheme.terracotta,
          ),
          (
            '19:00',
            'Arquitetura de Software',
            'Sala 210 · Bloco A',
            'Prof. F. Ramalho',
            OrbitaTheme.green,
          ),
          (
            '21:00',
            'Cálculo Numérico',
            'Sala 108 · Bloco A',
            'Prof. E. Villas',
            OrbitaTheme.amber,
          ),
          (
            '19:00',
            'Engenharia de Requisitos',
            'Sala 212 · Bloco A',
            'Prof.ª C. Bezerra',
            OrbitaTheme.alert,
          ),
        },
      );
    },
  );

  for (final (day, subjects) in [
    (ScheduleDay.monday, ['Inteligência Artificial', 'Banco de Dados II']),
    (ScheduleDay.tuesday, ['Arquitetura de Software']),
    (ScheduleDay.wednesday, ['Inteligência Artificial', 'Cálculo Numérico']),
    (ScheduleDay.thursday, ['Engenharia de Requisitos', 'Banco de Dados II']),
    (ScheduleDay.friday, ['Arquitetura de Software']),
    (ScheduleDay.saturday, <String>[]),
  ]) {
    testWidgets('${day.label} mostra apenas as aulas corretas', (tester) async {
      await openSchedule(tester, day);

      expect(find.text('HORÁRIO SEMANAL'), findsOneWidget);
      expect(find.text('Suas aulas'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(6));
      final selected = tester
          .widgetList<ChoiceChip>(find.byType(ChoiceChip))
          .where((chip) => chip.selected)
          .single;
      expect((selected.label as Text).data, day.abbreviation);
      expect(find.byType(Card), findsNWidgets(subjects.length));
      for (final subject in subjects) {
        expect(find.text(subject), findsOneWidget);
      }
      for (final lesson in demoSchedule[day]!) {
        expect(find.text(lesson.time), findsOneWidget);
        expect(find.text(lesson.room), findsOneWidget);
        expect(find.text(lesson.professor), findsOneWidget);
      }
      if (subjects.isEmpty) {
        expect(find.text('Sem aulas em Sábado'), findsOneWidget);
      } else {
        expect(find.textContaining('Sem aulas em'), findsNothing);
      }
    });
  }

  testWidgets('seleção muda aulas e não desmarca o dia ao tocar novamente', (
    tester,
  ) async {
    await openSchedule(tester, ScheduleDay.monday);
    expect(find.byType(Card), findsNWidgets(2));
    await selectDay(tester, ScheduleDay.tuesday);
    expect(find.text('Arquitetura de Software'), findsOneWidget);
    expect(find.text('Banco de Dados II'), findsNothing);
    expect(find.byType(Card), findsOneWidget);

    await selectDay(tester, ScheduleDay.tuesday);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'TER'))
          .selected,
      isTrue,
    );
    await selectDay(tester, ScheduleDay.saturday);
    expect(find.byType(Card), findsNothing);
    expect(find.text('Sem aulas em Sábado'), findsOneWidget);
  });

  testWidgets('dia selecionado persiste ao sair e voltar à aba Horário', (
    tester,
  ) async {
    await openSchedule(tester, ScheduleDay.saturday);
    final state = tester.state(find.byType(ScheduleScreen));
    await tester.tap(find.text('Notas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Horário'));
    await tester.pumpAndSettle();

    expect(tester.state(find.byType(ScheduleScreen)), same(state));
    expect(find.text('Sem aulas em Sábado'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'SÁB'))
          .selected,
      isTrue,
    );
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
  });

  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(360, 640),
  ]) {
    testWidgets('chips e aulas acessíveis sem overflow em $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await openSchedule(tester, ScheduleDay.monday);

      final lastClass = find.widgetWithText(Card, 'Banco de Dados II');
      await tester.ensureVisible(lastClass);
      await tester.pumpAndSettle();
      expect(lastClass.hitTestable(), findsOneWidget);
      await selectDay(tester, ScheduleDay.saturday);
      expect(find.text('Sem aulas em Sábado').hitTestable(), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
