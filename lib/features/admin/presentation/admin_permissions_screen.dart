import 'package:flutter/material.dart';

import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/admin.dart';
import '../data/admin_mock.dart';
import 'admin_login_screen.dart';

typedef RoleRequest = ({String account, String role, String validUntil});

class AdminPermissionsScreen extends StatefulWidget {
  const AdminPermissionsScreen({
    super.key,
    required this.requests,
    required this.onRequest,
    this.today,
  });

  final List<RoleRequest> requests;
  final ValueChanged<RoleRequest> onRequest;

  /// Data de referência para validar a vigência (substituível em testes).
  final DateTime? today;

  @override
  State<AdminPermissionsScreen> createState() => _AdminPermissionsScreenState();
}

class _AdminPermissionsScreenState extends State<AdminPermissionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _account = TextEditingController();
  final _validUntil = TextEditingController();
  final _justification = TextEditingController();
  var _role = adminRoles.first;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final account = _account.text.trim().toLowerCase();
    if (account == adminEmail) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Você não pode pedir papel para a própria conta.'),
          ),
        );
      return;
    }
    widget.onRequest((
      account: account,
      role: _role,
      validUntil: _validUntil.text.trim(),
    ));
    _formKey.currentState!.reset();
    for (final controller in [_account, _validUntil, _justification]) {
      controller.clear();
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Pedido enviado para aprovação de outro superadmin.'),
        ),
      );
  }

  @override
  void dispose() {
    for (final controller in [_account, _validUntil, _justification]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Conceder papel administrativo', style: textTheme.bodySmall),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LabeledField(
                      label: 'Conta administrativa',
                      child: TextFormField(
                        controller: _account,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: 'adm.nome@orbita.edu',
                        ),
                        validator: validateAdminEmail,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledField(
                      label: 'Papel',
                      child: DropdownButtonFormField<String>(
                        initialValue: _role,
                        isExpanded: true,
                        items: [
                          for (final role in adminRoles)
                            DropdownMenuItem(value: role, child: Text(role)),
                        ],
                        onChanged: (value) => setState(() => _role = value!),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledField(
                      label: 'Vigência até',
                      child: TextFormField(
                        controller: _validUntil,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          hintText: 'dd/mm/aaaa',
                        ),
                        validator: (value) => validateValidity(
                          value,
                          widget.today ?? DateTime.now(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledField(
                      label: 'Justificativa',
                      child: TextFormField(
                        controller: _justification,
                        minLines: 2,
                        maxLines: 4,
                        validator: (value) => (value ?? '').trim().length < 10
                            ? 'Justifique com ao menos 10 caracteres.'
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const InfoBanner(
              icon: Icons.group_outlined,
              title: 'Exige segunda aprovação',
              message: 'Outro superadmin precisa aprovar. Você não pode aprovar o próprio pedido.',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: adminButtonStyle,
              onPressed: _submit,
              icon: const Icon(Icons.send_outlined, size: 18),
              label: const Text('Enviar para aprovação'),
            ),
            if (widget.requests.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Aguardando aprovação', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final request in widget.requests)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InfoCard(
                    icon: Icons.admin_panel_settings_outlined,
                    title: '${request.role} · ${request.account}',
                    subtitle: 'Vigência até ${request.validUntil}',
                    trailing: const StatusTag(
                      label: 'Pendente',
                      tone: TagTone.warning,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
