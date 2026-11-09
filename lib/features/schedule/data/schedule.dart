import 'package:flutter/painting.dart';

enum ScheduleDay {
  monday('SEG', 'Segunda'),
  tuesday('TER', 'Terça'),
  wednesday('QUA', 'Quarta'),
  thursday('QUI', 'Quinta'),
  friday('SEX', 'Sexta'),
  saturday('SÁB', 'Sábado');

  const ScheduleDay(this.abbreviation, this.label);

  final String abbreviation;
  final String label;

  // shortcut: domingo usa sábado como no legado, revisar ao adicionar calendário real.
  static ScheduleDay forDate(DateTime date) =>
      date.weekday == DateTime.sunday ? saturday : values[date.weekday - 1];
}

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
}
