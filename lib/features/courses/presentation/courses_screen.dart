import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/page_heading.dart';
import '../../../core/widgets/status_tag.dart';
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
          PageHeading(
            overline: 'Semestre 2026.2 · atual',
            title: 'Minhas disciplinas',
            trailing: TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.materials),
              child: const Text('ver materiais'),
            ),
          ),
          const SizedBox(height: 12),
          for (final course in demoCourses)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
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
                                Text(
                                  course.subject,
                                  style: textTheme.bodyLarge,
                                ),
                                Text(course.professor),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusTag(
                            label: '${course.credits} créditos',
                            tone: TagTone.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: course.progress / 100,
                          color: OrbitaTheme.terracotta,
                          semanticsLabel:
                              'Progresso do semestre em ${course.subject}',
                        ),
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
            ),
        ],
      ),
    );
  }
}
