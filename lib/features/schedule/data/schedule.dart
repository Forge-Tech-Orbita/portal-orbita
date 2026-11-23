import 'package:flutter/painting.dart';

enum ScheduleDay {
  monday('SEG', 'Segunda', 'segunda'),
  tuesday('TER', 'Terça', 'terça'),
  wednesday('QUA', 'Quarta', 'quarta'),
  thursday('QUI', 'Quinta', 'quinta'),
  friday('SEX', 'Sexta', 'sexta'),
  saturday('SÁB', 'Sábado', 'sábado');

  const ScheduleDay(this.abbreviation, this.label, this.lowercase);

  final String abbreviation;
  final String label;
  final String lowercase;

  // shortcut: domingo usa sábado como no legado, revisar ao adicionar calendário real.
  static ScheduleDay forDate(DateTime date) =>
      date.weekday == DateTime.sunday ? saturday : values[date.weekday - 1];
}

const _weekdayNames = [
  'segunda',
  'terça',
  'quarta',
  'quinta',
  'sexta',
  'sábado',
  'domingo',
];

String weekdayName(DateTime date) => _weekdayNames[date.weekday - 1];

class ScheduledClass {
  const ScheduledClass({
    required this.time,
    required this.subject,
    required this.room,
    required this.professor,
    required this.color,
  });

  final String time;
  final String subject;
  final String room;
  final String professor;
  final Color color;

  int get minutesOfDay {
    final [hour, minute] = time.split(':').map(int.parse).toList();
    return hour * 60 + minute;
  }
}

typedef NextClass = ({ScheduledClass lesson, String when, String? startsIn});

/// Próxima aula a partir de [now], procurando até uma semana adiante.
NextClass? nextClassFrom(
  Map<ScheduleDay, List<ScheduledClass>> schedule,
  DateTime now,
) {
  final nowMinutes = now.hour * 60 + now.minute;
  for (var offset = 0; offset < 7; offset++) {
    final date = now.add(Duration(days: offset));
    if (date.weekday == DateTime.sunday) continue;
    final lessons = [...?schedule[ScheduleDay.forDate(date)]]
      ..sort((a, b) => a.minutesOfDay.compareTo(b.minutesOfDay));
    for (final lesson in lessons) {
      if (offset == 0 && lesson.minutesOfDay <= nowMinutes) continue;
      if (offset == 0) {
        final diff = lesson.minutesOfDay - nowMinutes;
        final startsIn = diff < 60
            ? 'em $diff min'
            : 'em ${diff ~/ 60}h${(diff % 60).toString().padLeft(2, '0')}';
        return (
          lesson: lesson,
          when: 'Hoje · ${lesson.time}',
          startsIn: startsIn,
        );
      }
      final day = ScheduleDay.forDate(date).abbreviation;
      final label = '${day[0]}${day.substring(1).toLowerCase()}';
      return (lesson: lesson, when: '$label · ${lesson.time}', startsIn: null);
    }
  }
  return null;
}
