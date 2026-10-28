import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/orbita_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/financial/presentation/financial_screen.dart';
import 'features/library/presentation/library_screen.dart';
import 'features/navigation/presentation/main_navigation_screen.dart';
import 'features/notices/presentation/notices_screen.dart';
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
        final screen = switch (settings.name) {
          AppRoutes.login => const LoginScreen(),
          AppRoutes.main => const MainNavigationScreen(),
          AppRoutes.financial => const FinancialScreen(),
          AppRoutes.library => const LibraryScreen(),
          AppRoutes.notices => const NoticesScreen(),
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
