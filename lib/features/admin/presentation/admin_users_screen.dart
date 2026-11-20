import 'package:flutter/material.dart';

import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/admin.dart';
import 'admin_login_screen.dart';

typedef Invite = ({String email, String role});

TagTone accountTone(AccountStatus status) => switch (status) {
  AccountStatus.active => TagTone.success,
  AccountStatus.blocked => TagTone.danger,
  AccountStatus.pending => TagTone.warning,
};

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({
    super.key,
    required this.accounts,
    required this.onToggleBlock,
    required this.onInvite,
  });

  final List<AdminAccount> accounts;
  final ValueChanged<AdminAccount> onToggleBlock;
  final ValueChanged<Invite> onInvite;

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _search = TextEditingController();
  var _group = AccountGroup.academic;

  Future<void> _openAccount(AdminAccount account) async {
    final toggle = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(account.name),
              subtitle: Text('${account.detail} · ${account.status.label}'),
            ),
            if (account.status != AccountStatus.pending)
              ListTile(
                leading: Icon(
                  account.status == AccountStatus.blocked
                      ? Icons.lock_open_outlined
                      : Icons.block,
                  color: OrbitaTheme.terracotta,
                ),
                title: Text(
                  account.status == AccountStatus.blocked
                      ? 'Desbloquear conta'
                      : 'Bloquear conta',
                ),
                onTap: () => Navigator.of(context).pop(true),
              ),
          ],
        ),
      ),
    );
    if (toggle == true) widget.onToggleBlock(account);
  }

  Future<void> _invite() async {
    final invite = await showDialog<Invite>(
      context: context,
      builder: (_) => const _InviteDialog(),
    );
    if (invite != null) widget.onInvite(invite);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final accounts = widget.accounts.where(
      (account) =>
          account.group == _group &&
          (query.isEmpty ||
              account.name.toLowerCase().contains(query) ||
              account.detail.toLowerCase().contains(query)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            decoration: const InputDecoration(
              hintText: 'Nome, matrícula ou e-mail',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final (group, label) in const [
                (AccountGroup.academic, 'Acadêmicos'),
                (AccountGroup.administrative, 'Administrativos'),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: _group == group,
                  onSelected: (_) => setState(() => _group = group),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (accounts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Nenhuma conta encontrada.'),
            ),
          for (final account in accounts)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InfoCard(
                icon: Icons.person_outline,
                title: account.name,
                subtitle: account.detail,
                trailing: StatusTag(
                  label: account.status.label,
                  tone: accountTone(account.status),
                ),
                onTap: () => _openAccount(account),
              ),
            ),
          const SizedBox(height: 4),
          FilledButton.icon(
            style: adminButtonStyle,
            onPressed: _invite,
            icon: const Icon(Icons.add),
            label: const Text('Convidar usuário'),
          ),
          const SizedBox(height: 8),
          Text(
            'Mostrando dados mínimos · CPF e notas não aparecem aqui',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InviteDialog extends StatefulWidget {
  const _InviteDialog();

  @override
  State<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<_InviteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  var _role = 'Professor';

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Convidar usuário'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail institucional',
              ),
              validator: (value) =>
                  (value ?? '').trim().toLowerCase().endsWith('@orbita.edu')
                  ? null
                  : 'Use um e-mail @orbita.edu.',
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Perfil'),
              items: [
                for (final role in const ['Aluno', 'Professor', 'Coordenação'])
                  DropdownMenuItem(value: role, child: Text(role)),
              ],
              onChanged: (value) => setState(() => _role = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: adminButtonStyle,
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context)
                .pop<Invite>((email: _email.text.trim(), role: _role));
          },
          child: const Text('Enviar convite'),
        ),
      ],
    );
  }
}
