import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/mock/notices_mock.dart';
import '../../../core/mock/student_mock.dart';
import '../../auth/data/academic_session.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/widgets/notice_tile.dart';
import '../../../core/widgets/page_heading.dart';
import '../../../core/widgets/student_id_card.dart';
import 'widgets/next_class_card.dart';
import 'widgets/quick_action_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.nextClass, required this.notifications});

  final HomeNextClass? nextClass;

  /// Notificações compartilhadas com a tela de notificações (badge do sino).
  final ValueNotifier<List<AppNotification>> notifications;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final student =
        AcademicSessionScope.maybeOf(context)?.profile?.student ?? demoStudent;
    final nextClass = this.nextClass;

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
                    Text(
                      greetingForHour(DateTime.now().hour),
                      style: textTheme.bodySmall,
                    ),
                    Text(student.shortName, style: textTheme.titleLarge),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: notifications,
                builder: (context, items, _) {
                  final unread = items.where((item) => !item.read).length;
                  return IconButton(
                    tooltip: unread == 0
                        ? 'Notificações'
                        : 'Notificações, $unread não lidas',
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.notifications,
                      arguments: notifications,
                    ),
                    icon: Badge(
                      isLabelVisible: unread > 0,
                      label: Text('$unread'),
                      child: const Icon(Icons.notifications_outlined),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          StudentIdCard(student: student),
          if (nextClass != null) ...[
            const SizedBox(height: 12),
            NextClassCard(nextClass: nextClass),
          ],
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          SectionHeader(
            title: 'Mural recente',
            actionLabel: 'ver tudo',
            onAction: () => Navigator.of(context).pushNamed(AppRoutes.notices),
          ),
          for (final notice in recentNotices) ...[
            NoticeTile(notice: notice, compact: true),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
