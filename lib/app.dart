import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'core/models/app_notification.dart';
import 'core/theme/orbita_theme.dart';
import 'features/admin/presentation/admin_login_screen.dart';
import 'features/admin/presentation/admin_mfa_screen.dart';
import 'features/admin/presentation/admin_shell.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/coordination/data/coordination_mock.dart';
import 'features/coordination/presentation/coordination_shell.dart';
import 'features/financial/presentation/financial_screen.dart';
import 'features/financial/presentation/payment_screen.dart';
import 'features/library/presentation/catalog_screen.dart';
import 'features/library/presentation/library_screen.dart';
import 'features/materials/presentation/materials_screen.dart';
import 'features/materials/presentation/new_material_screen.dart';
import 'features/navigation/presentation/main_navigation_screen.dart';
import 'features/notices/presentation/notices_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/professor/data/professor_mock.dart';
import 'features/professor/presentation/professor_shell.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/support/data/support_ticket.dart';
import 'features/support/presentation/new_ticket_screen.dart';
import 'features/support/presentation/support_screen.dart';
import 'features/support/presentation/ticket_sent_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Órbita',
      theme: OrbitaTheme.data,
      initialRoute: AppRoutes.login,
      onGenerateRoute: (settings) {
        final arguments = settings.arguments;
        final screen = switch (settings.name) {
          AppRoutes.login => const LoginScreen(),
          AppRoutes.main => const MainNavigationScreen(),
          AppRoutes.financial => const FinancialScreen(),
          AppRoutes.payment => PaymentScreen(
            initialMethod: arguments is PaymentMethod
                ? arguments
                : PaymentMethod.pix,
          ),
          AppRoutes.library => const LibraryScreen(),
          AppRoutes.catalog => CatalogScreen(
            initial: arguments is CatalogQuery
                ? arguments
                : const CatalogQuery(),
          ),
          AppRoutes.materials => const MaterialsScreen(),
          AppRoutes.notices => const NoticesScreen(),
          AppRoutes.notifications => NotificationsScreen(
            notifications: arguments is ValueNotifier<List<AppNotification>>
                ? arguments
                : null,
          ),
          AppRoutes.support => const SupportScreen(),
          AppRoutes.newTicket => const NewTicketScreen(),
          AppRoutes.ticketSent when arguments is SupportTicket =>
            TicketSentScreen(ticket: arguments),
          AppRoutes.profile => const ProfileScreen(),
          AppRoutes.professor => const ProfessorShell(),
          AppRoutes.professorNewMaterial => NewMaterialScreen(
            audienceLabel: 'Para qual turma',
            author: professorName,
            audienceOptions: [
              for (final teachingClass in teachingClasses)
                (
                  label: '${teachingClass.code} · ${teachingClass.subject}',
                  audiences: [teachingClass.code],
                ),
            ],
          ),
          AppRoutes.coordination => const CoordinationShell(),
          AppRoutes.coordinationNewMaterial => const NewMaterialScreen(
            audienceLabel: 'Para quem',
            author: 'Coordenação',
            audienceOptions: coordinationAudiences,
          ),
          AppRoutes.adminLogin => const AdminLoginScreen(),
          AppRoutes.adminMfa => const AdminMfaScreen(),
          AppRoutes.admin => const AdminShell(),
          _ => const Scaffold(
            body: SafeArea(child: Center(child: Text('Rota não encontrada'))),
          ),
        };

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => screen,
        );
      },
    );
  }
}
