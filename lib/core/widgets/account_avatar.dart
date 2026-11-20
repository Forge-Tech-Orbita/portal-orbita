import 'package:flutter/material.dart';

import '../constants/app_routes.dart';
import '../theme/orbita_theme.dart';

/// Encerra a sessão acadêmica e limpa a pilha de navegação.
void signOut(BuildContext context, {String route = AppRoutes.login}) {
  Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
}

/// Avatar com iniciais que abre o menu da conta (encerrar sessão).
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({
    super.key,
    required this.initials,
    required this.name,
    required this.role,
  });

  final String initials;
  final String name;
  final String role;

  Future<void> _openMenu(BuildContext context) async {
    final leave = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: OrbitaTheme.text,
                foregroundColor: OrbitaTheme.surface,
                child: Text(initials),
              ),
              title: Text(name),
              subtitle: Text(role),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: OrbitaTheme.terracotta),
              title: const Text('Encerrar sessão'),
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
    if (leave == true && context.mounted) signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Conta de $name',
      excludeSemantics: true,
      child: Tooltip(
        message: 'Conta',
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _openMenu(context),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: OrbitaTheme.text,
            foregroundColor: OrbitaTheme.surface,
            child: Text(
              initials,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
