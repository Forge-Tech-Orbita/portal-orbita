import 'package:flutter/material.dart';

import '../../../core/widgets/page_heading.dart';
import '../data/schedule.dart';
import '../data/schedule_mock.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, this.now});

  /// Data de referência, substituível em testes.
  final DateTime? now;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late final DateTime _today = widget.now ?? DateTime.now();
  late ScheduleDay _currentDay = ScheduleDay.forDate(_today);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lessons = demoSchedule[_currentDay]!;
    final todayLabel =
        '${ScheduleDay.forDate(_today).lowercase}, '
        '${_today.day.toString().padLeft(2, '0')}/'
        '${_today.month.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeading(overline: 'Horário semanal', title: 'Suas aulas'),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 6,
              children: [
                for (final day in ScheduleDay.values)
                  ChoiceChip(
                    label: Text(day.abbreviation),
                    tooltip: day.label,
                    selected: day == _currentDay,
                    onSelected: (_) => setState(() => _currentDay = day),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Abre no dia de hoje ($todayLabel). '
            'Grade da turma $scheduleGroup, $scheduleTerm.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (lessons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 34),
                  const SizedBox(height: 12),
                  Text(
                    'Sem aulas em ${_currentDay.label}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          for (final lesson in lessons)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 14,
                    children: [
                      Column(
                        children: [
                          Text(lesson.time, style: textTheme.labelLarge),
                          const SizedBox(height: 6),
                          ExcludeSemantics(
                            child: Icon(
                              Icons.circle,
                              size: 8,
                              color: lesson.color,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lesson.subject, style: textTheme.bodyLarge),
                            Text(lesson.room),
                            Text(lesson.professor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
