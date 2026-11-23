import 'package:flutter/material.dart';

import '../../../core/widgets/page_heading.dart';
import '../../../core/widgets/status_tag.dart';
import '../../../core/theme/orbita_colors.dart';
import '../data/coordination.dart';
import '../data/coordination_mock.dart';

enum ClassFilter {
  all('Todas'),
  sixthPeriod('6º período'),
  atRisk('Em risco');

  const ClassFilter(this.label);

  final String label;

  bool matches(CourseClass courseClass) => switch (this) {
    ClassFilter.all => true,
    ClassFilter.sixthPeriod => courseClass.period == 6,
    ClassFilter.atRisk => courseClass.atRisk,
  };
}

class CoordinationClassesScreen extends StatelessWidget {
  const CoordinationClassesScreen({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  final ClassFilter filter;
  final ValueChanged<ClassFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final colors = OrbitaColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final classes = courseClasses.where(filter.matches);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeading(
            overline: 'Engenharia de Software · 2026.2',
            title: 'Turmas do curso',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final option in ClassFilter.values)
                ChoiceChip(
                  label: Text(option.label),
                  selected: option == filter,
                  onSelected: (_) => onFilterChanged(option),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (final courseClass in classes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_outlined, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              courseClass.subject,
                              style: textTheme.bodyLarge,
                            ),
                            Text(
                              '${courseClass.code} · ${courseClass.professor}',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          spacing: 4,
                          children: [
                            StatusTag(
                              label:
                                  'Média ${formatAverage(courseClass.average)}',
                              tone: courseClass.average < 7
                                  ? TagTone.warning
                                  : TagTone.success,
                            ),
                            StatusTag(
                              label: 'Freq. ${courseClass.attendance}%',
                              tone: courseClass.attendance < 85
                                  ? TagTone.warning
                                  : TagTone.neutral,
                            ),
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
