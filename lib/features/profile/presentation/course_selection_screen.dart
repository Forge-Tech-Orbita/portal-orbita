import 'package:flutter/material.dart';

import '../../../core/constants/institution_catalog.dart';
import '../../auth/data/academic_session.dart';

class CourseSelectionScreen extends StatelessWidget {
  const CourseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AcademicSessionScope.maybeOf(context)!;
    final profile = session.profile!;
    final institution = institutions[profile.institutionId]!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolher curso'),
        actions: [
          IconButton(
            tooltip: 'Encerrar sessão',
            onPressed: session.signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(institution.name),
            const Text(
              'Escolha seu curso. O vínculo não poderá ser alterado nesta versão.',
            ),
            if (session.error case final String error) Text(error),
            if (session.activeCourseIds.isEmpty)
              const Text(
                'Nenhum curso ativo disponível. Entre em contato com a instituição.',
              ),
            for (final entry in institution.courses.entries.where(
              (entry) => session.activeCourseIds.contains(entry.key),
            ))
              ListTile(
                title: Text(entry.value),
                enabled: !session.loading,
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Vincular ${entry.value}?'),
                      content: const Text(
                        'A escolha é única e não cria notas ou disciplinas.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Confirmar'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await session.chooseCourse(entry.key);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
