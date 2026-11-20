import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/page_heading.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeading(overline: 'Atalhos', title: 'Mais opções'),
          const SizedBox(height: 12),
          for (final (label, description, icon, route) in const [
            (
              'Financeiro',
              'Mensalidades e pagamentos',
              Icons.credit_card_outlined,
              AppRoutes.financial,
            ),
            (
              'Biblioteca',
              'Acervo e empréstimos',
              Icons.menu_book_outlined,
              AppRoutes.library,
            ),
            (
              'Materiais das disciplinas',
              'PDFs e links dos professores e da coordenação',
              Icons.description_outlined,
              AppRoutes.materials,
            ),
            (
              'Mural de avisos',
              'Comunicados e eventos',
              Icons.notifications_outlined,
              AppRoutes.notices,
            ),
            (
              'Suporte',
              'Chamados e perguntas frequentes',
              Icons.help_outline,
              AppRoutes.support,
            ),
            (
              'Meu perfil',
              'Dados pessoais e preferências',
              Icons.person_outline,
              AppRoutes.profile,
            ),
            (
              'Sair',
              'Encerrar sessão neste aparelho',
              Icons.logout,
              AppRoutes.login,
            ),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InfoCard(
                title: label,
                subtitle: description,
                icon: icon,
                iconColor: route == AppRoutes.login
                    ? OrbitaTheme.terracotta
                    : OrbitaTheme.primary,
                showChevron: route != AppRoutes.login,
                onTap: () {
                  if (route == AppRoutes.login) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(route, (_) => false);
                  } else {
                    Navigator.of(context).pushNamed(route);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
