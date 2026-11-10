import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/mock/notices_mock.dart';
import '../../../core/mock/student_mock.dart';
import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/notice_tile.dart';
import '../../../core/widgets/student_id_card.dart';
import 'widgets/academic_stat_tile.dart';
import 'widgets/next_class_card.dart';
import 'widgets/quick_action_tile.dart';

String greetingForHour(int hour) =>
    hour < 12 ? 'Bom dia' : (hour < 18 ? 'Boa tarde' : 'Boa noite');

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greetingForHour(DateTime.now().hour)),
                    Text(demoStudent.shortName, style: textTheme.headlineSmall),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Abrir mural de avisos',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.notices),
                icon: const Badge(child: Icon(Icons.notifications_outlined)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const StudentIdCard(student: demoStudent),
          const SizedBox(height: 16),
          const Row(
            spacing: 8,
            children: [
              Expanded(
                child: AcademicStatTile(value: '8.7', label: 'CRA geral'),
              ),
              Expanded(
                child: AcademicStatTile(value: '94%', label: 'Frequência'),
              ),
              Expanded(
                child: AcademicStatTile(value: '142', label: 'Créditos'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // shortcut: próxima aula e tempo fixos do protótipo, calcular quando houver agenda real.
          const NextClassCard(
            subject: 'Inteligência Artificial',
            details: 'Sala 304 · Bloco C · Prof. R. Nakamura',
            time: '19:00',
            startsIn: 'em 47 min',
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              for (final (label, icon, route) in const [
                ('Financeiro', Icons.credit_card_outlined, AppRoutes.financial),
                ('Biblioteca', Icons.menu_book_outlined, AppRoutes.library),
                ('Avisos', Icons.notifications_outlined, AppRoutes.notices),
                ('Suporte', Icons.help_outline, AppRoutes.support),
              ])
                Expanded(
                  child: QuickActionTile(
                    label: label,
                    icon: icon,
                    onTap: () => Navigator.of(context).pushNamed(route),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text('Mural recente', style: textTheme.titleMedium),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.notices),
                child: const Text('ver tudo'),
              ),
            ],
          ),
          Card(
            margin: EdgeInsets.zero,
            color: OrbitaTheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final notice in demoNotices.take(3))
                    NoticeTile(notice: notice, compact: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
