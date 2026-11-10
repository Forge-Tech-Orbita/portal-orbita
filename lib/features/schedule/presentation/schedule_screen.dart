import 'package:flutter/material.dart';

import '../../../core/theme/orbita_theme.dart';
import '../data/schedule.dart';
import '../data/schedule_mock.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  ScheduleDay _currentDay = ScheduleDay.forDate(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lessons = demoSchedule[_currentDay]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('HORÁRIO SEMANAL', style: textTheme.labelMedium),
          Text('Suas aulas', style: textTheme.headlineSmall),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
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
          const SizedBox(height: 16),
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
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: OrbitaTheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Column(
                      children: [
                        Text(lesson.time, style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Icon(Icons.circle, size: 10, color: lesson.color),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lesson.subject, style: textTheme.titleSmall),
                          Text(lesson.room),
                          Text(lesson.professor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
