import 'package:flutter/material.dart';

import '../../../core/theme/orbita_theme.dart';
import '../data/courses_mock.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('SEMESTRE 2026.2', style: textTheme.labelMedium),
          Text('Minhas disciplinas', style: textTheme.headlineSmall),
          const SizedBox(height: 16),
          for (final course in demoCourses)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: OrbitaTheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(course.subject, style: textTheme.titleSmall),
                              Text(course.professor),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: OrbitaTheme.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${course.credits} créditos',
                            style: textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: course.progress / 100,
                      color: OrbitaTheme.terracotta,
                      semanticsLabel:
                          'Progresso do semestre em ${course.subject}',
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        Text(
                          '${course.progress}% do semestre',
                          style: textTheme.bodySmall,
                        ),
                        Text(course.room, style: textTheme.bodySmall),
                      ],
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
