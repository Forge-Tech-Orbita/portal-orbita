import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Mais opções — em migração'),
        for (final (label, route) in const [
          ('Financeiro', AppRoutes.financial),
          ('Biblioteca', AppRoutes.library),
          ('Mural', AppRoutes.notices),
          ('Perfil', AppRoutes.profile),
          ('Suporte', AppRoutes.support),
        ])
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(route),
            child: Text(label),
          ),
        TextButton(
          onPressed: () =>
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false),
          child: const Text('Sair'),
        ),
      ],
    );
  }
}
