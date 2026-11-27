import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/orbita_colors.dart';
import '../../../core/widgets/page_heading.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/course.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key, required this.courses, this.semester});

  final List<Course> courses;
  final String? semester;

  @override
  Widget build(BuildContext context) {
    final colors = OrbitaColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final term = semester?.replaceFirst('-', '.');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeading(
            overline: term == null || courses.isEmpty
                ? 'Disciplinas demonstrativas'
                : 'Semestre $term · atual',
            title: 'Minhas disciplinas',
            trailing: Flexible(
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.materials),
                child: const Text('ver materiais', textAlign: TextAlign.center),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (courses.isEmpty)
            const Text('Nenhuma disciplina demonstrativa para este perfil.'),
          for (final course in courses)
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
                          color: colors.secondary,
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
