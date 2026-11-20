import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'core/models/app_notification.dart';
import 'core/theme/orbita_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/financial/presentation/financial_screen.dart';
import 'features/financial/presentation/payment_screen.dart';
import 'features/library/presentation/library_screen.dart';
import 'features/materials/presentation/materials_screen.dart';
import 'features/navigation/presentation/main_navigation_screen.dart';
import 'features/notices/presentation/notices_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/support/presentation/support_screen.dart';

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
          AppRoutes.materials => const MaterialsScreen(),
          AppRoutes.notices => const NoticesScreen(),
          AppRoutes.notifications => NotificationsScreen(
            notifications: arguments is ValueNotifier<List<AppNotification>>
                ? arguments
                : null,
          ),
          AppRoutes.support => const SupportScreen(),
          AppRoutes.profile => const ProfileScreen(),
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
