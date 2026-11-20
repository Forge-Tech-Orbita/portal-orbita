import 'package:flutter/material.dart';

import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/page_heading.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/professor_mock.dart';

class ProfessorClassesScreen extends StatelessWidget {
  const ProfessorClassesScreen({
    super.key,
    required this.materialCountFor,
    required this.onOpenClass,
  });

  final int Function(String classCode) materialCountFor;
  final ValueChanged<String> onOpenClass;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeading(
            overline: 'Semestre 2026.2',
            title: 'Minhas turmas',
            subtitle: 'Somente turmas vinculadas a você',
          ),
          const SizedBox(height: 12),
          for (final teachingClass in teachingClasses)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InfoCard(
                icon: Icons.group_outlined,
                title: teachingClass.subject,
                subtitle:
                    '${teachingClass.code} · ${teachingClass.students} alunos · ${teachingClass.room}',
                trailing: StatusTag(
                  label: '${materialCountFor(teachingClass.code)} materiais',
                  tone: TagTone.neutral,
                ),
                showChevron: true,
                onTap: () => onOpenClass(teachingClass.code),
              ),
            ),
        ],
      ),
    );
  }
}
