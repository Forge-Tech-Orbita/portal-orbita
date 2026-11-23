import 'package:flutter/material.dart';

import '../constants/app_routes.dart';
import '../../features/auth/data/academic_session.dart';
import '../theme/orbita_colors.dart';

/// Encerra a sessão acadêmica e limpa a pilha de navegação.
Future<void> signOut(
  BuildContext context, {
  String route = AppRoutes.login,
}) async {
  final session = AcademicSessionScope.maybeOf(context);
  if (session != null &&
      (session.hasAccount || session.loading || session.error != null)) {
    await session.signOut();
    if (!context.mounted || session.error != null) return;
  }
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
    final colors = OrbitaColors.of(context);
    final leave = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: colors.text,
                foregroundColor: colors.surface,
                child: Text(initials),
              ),
              title: Text(name),
              subtitle: Text(role),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: colors.secondary),
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
    final colors = OrbitaColors.of(context);
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
            backgroundColor: colors.text,
            foregroundColor: colors.surface,
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
