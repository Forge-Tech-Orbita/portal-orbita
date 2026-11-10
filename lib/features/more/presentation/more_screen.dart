import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/orbita_theme.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('NAVEGAÇÃO', style: textTheme.labelMedium),
          Text('Mais opções', style: textTheme.headlineSmall),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final (label, description, icon, route) in const [
                  (
                    'Financeiro',
                    'Boletos e pagamentos',
                    Icons.credit_card_outlined,
                    AppRoutes.financial,
                  ),
                  (
                    'Biblioteca',
                    'Empréstimos e acervo',
                    Icons.menu_book_outlined,
                    AppRoutes.library,
                  ),
                  (
                    'Mural',
                    'Avisos e comunicados',
                    Icons.notifications_outlined,
                    AppRoutes.notices,
                  ),
                  (
                    'Perfil',
                    'Dados e configurações',
                    Icons.person_outline,
                    AppRoutes.profile,
                  ),
                  (
                    'Suporte',
                    'Central de ajuda',
                    Icons.help_outline,
                    AppRoutes.support,
                  ),
                  ('Sair', 'Encerrar sessão', Icons.logout, AppRoutes.login),
                ])
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: OutlinedButton(
                      onPressed: () {
                        if (route == AppRoutes.login) {
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil(route, (_) => false);
                        } else {
                          Navigator.of(context).pushNamed(route);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(16),
                        backgroundColor: OrbitaTheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            icon,
                            color: route == AppRoutes.login
                                ? OrbitaTheme.alert
                                : OrbitaTheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(label, style: textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(description, style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
