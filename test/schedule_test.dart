import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/features/schedule/data/schedule.dart';
import 'package:portal_orbita/features/schedule/data/schedule_mock.dart';
import 'package:portal_orbita/features/schedule/presentation/schedule_screen.dart';

import 'helpers.dart';

final thursday = DateTime(2026, 11, 19, 20, 35);

void main() {
  test('domingo usa sábado e demais dias seguem a semana', () {
    expect(ScheduleDay.forDate(DateTime(2026, 11, 22)), ScheduleDay.saturday);
    expect(ScheduleDay.forDate(thursday), ScheduleDay.thursday);
    expect(ScheduleDay.forDate(DateTime(2026, 11, 16)), ScheduleDay.monday);
  });

  test('weekdayName retorna o nome correto do dia da semana', () {
    expect(weekdayName(DateTime(2026, 11, 29)), 'domingo');
    expect(weekdayName(DateTime(2026, 11, 25)), 'quarta');
    expect(weekdayName(DateTime(2026, 11, 28)), 'sábado');
  });

  test('quinta tem Arquitetura às 19:00 e Requisitos às 21:00', () {
    final lessons = demoSchedule[ScheduleDay.thursday]!;
    expect(lessons.map((lesson) => (lesson.time, lesson.subject)), [
      ('19:00', 'Arquitetura de Software'),
      ('21:00', 'Engenharia de Requisitos'),
    ]);
    expect(demoSchedule[ScheduleDay.saturday], isEmpty);
  });

  test('próxima aula é calculada pela grade', () {
    final today = nextClassFrom(demoSchedule, thursday)!;
    expect(today.lesson.subject, 'Engenharia de Requisitos');
    expect(today.when, 'Hoje · 21:00');
    expect(today.startsIn, 'em 25 min');

    final early = nextClassFrom(demoSchedule, DateTime(2026, 11, 19, 17, 0))!;
    expect(early.lesson.subject, 'Arquitetura de Software');
    expect(early.startsIn, 'em 2h00');

    final afterLast = nextClassFrom(
      demoSchedule,
      DateTime(2026, 11, 21, 22, 0),
    )!;
    expect(afterLast.when, 'Seg · 19:00');
    expect(afterLast.startsIn, isNull);
    expect(nextClassFrom({}, thursday), isNull);
  });

  test('próxima aula inclui ocorrência após 7 dias quando há aula em um só dia da semana', () {
    const singleWednesdayLesson = ScheduledClass(
      time: '08:00',
      subject: 'Laboratório de Redes',
      room: 'Lab 01',
      professor: 'Prof. Teste',
      color: Colors.blue,
    );
    final singleDaySchedule = <ScheduleDay, List<ScheduledClass>>{
      ScheduleDay.monday: [],
      ScheduleDay.tuesday: [],
      ScheduleDay.wednesday: [singleWednesdayLesson],
      ScheduleDay.thursday: [],
      ScheduleDay.friday: [],
      ScheduleDay.saturday: [],
    };

    // 1. Consulta após a última aula do dia (quarta 25/11 às 11:00) retorna aula de 7 dias depois
    final afterClass = nextClassFrom(
      singleDaySchedule,
      DateTime(2026, 11, 25, 11, 0),
    );
    expect(afterClass, isNotNull);
    expect(afterClass!.lesson.subject, 'Laboratório de Redes');
    expect(afterClass.when, 'Qua · 08:00');
    expect(afterClass.startsIn, isNull);

    // 2. Consulta antes da aula, no mesmo dia, retorna a aula de hoje
    final beforeClass = nextClassFrom(
      singleDaySchedule,
      DateTime(2026, 11, 25, 7, 0),
    );
    expect(beforeClass, isNotNull);
    expect(beforeClass!.lesson.subject, 'Laboratório de Redes');
    expect(beforeClass.when, 'Hoje · 08:00');
    expect(beforeClass.startsIn, 'em 1h00');

    // 3. Consulta em outro dia da semana continua retornando a próxima ocorrência
    final otherDay = nextClassFrom(
      singleDaySchedule,
      DateTime(2026, 11, 24, 10, 0),
    );
    expect(otherDay, isNotNull);
    expect(otherDay!.lesson.subject, 'Laboratório de Redes');
    expect(otherDay.when, 'Qua · 08:00');
    expect(otherDay.startsIn, isNull);
  });

  test('nextClassFrom preserva retorno null para grade vazia', () {
    expect(nextClassFrom({}, thursday), isNull);
    expect(
      nextClassFrom({for (final day in ScheduleDay.values) day: []}, thursday),
      isNull,
    );
  });

  testWidgets('abre no dia de hoje e troca de dia pelos chips', (tester) async {
    await pumpScreen(tester, Scaffold(body: ScheduleScreen(now: thursday)));

    expect(find.text('Suas aulas'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'QUI'))
          .selected,
      isTrue,
    );
    expect(
      find.textContaining('Abre no dia de hoje (quinta, 19/11)'),
      findsOne,
    );
    expect(find.text('Arquitetura de Software'), findsOneWidget);
    expect(find.text('Engenharia de Requisitos'), findsOneWidget);

    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'SÁB'));
    expect(find.text('Sem aulas em Sábado'), findsOneWidget);

    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'SEG'));
    expect(find.text('Inteligência Artificial'), findsOneWidget);
    expect(find.text('Banco de Dados II'), findsOneWidget);
  });

  testWidgets('domingo exibe legenda de domingo e seleciona sábado', (
    tester,
  ) async {
    final sunday = DateTime(2026, 11, 29, 10, 0);
    await pumpScreen(tester, Scaffold(body: ScheduleScreen(now: sunday)));

    expect(
      find.textContaining('Abre no dia de hoje (domingo, 29/11)'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'SÁB'))
          .selected,
      isTrue,
    );
  });

  testWidgets('dia comum exibe o nome do dia na legenda', (tester) async {
    final wednesday = DateTime(2026, 11, 25, 10, 0);
    await pumpScreen(tester, Scaffold(body: ScheduleScreen(now: wednesday)));

    expect(
      find.textContaining('Abre no dia de hoje (quarta, 25/11)'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'QUA'))
          .selected,
      isTrue,
    );
  });

  for (final size in testViewports) {
    testWidgets('chips e aulas alcançáveis sem overflow em $size', (
      tester,
    ) async {
      useViewport(tester, size, textScale: 1.5);
      await pumpScreen(tester, Scaffold(body: ScheduleScreen(now: thursday)));
      await tester.ensureVisible(find.text('Prof.ª C. Bezerra'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
