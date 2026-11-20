import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/orbita_colors.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/orbit_logo.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/admin.dart';
import '../data/admin_mock.dart';

/// Estilo dos botões principais do portal administrativo (escuros).
ButtonStyle adminButtonStyle(BuildContext context) {
  final colors = OrbitaColors.of(context);
  return FilledButton.styleFrom(
    backgroundColor: colors.text,
    foregroundColor: colors.surface,
  );
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: adminEmail);
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _continue() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    // shortcut: credencial administrativa simulada; integrar SSO/IdP em etapa própria.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() => _loading = false);
    Navigator.of(context).pushNamed(AppRoutes.adminMfa);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrbitaColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    const OrbitLogo(tagline: 'PORTAL ADMINISTRATIVO'),
                    const SizedBox(height: 24),
                    const InfoBanner(
                      icon: Icons.shield_outlined,
                      tone: TagTone.info,
                      title: 'Conta administrativa separada',
                      message: 'Contas de aluno, professor ou coordenação não entram aqui.',
                    ),
                    const SizedBox(height: 16),
                    LabeledField(
                      label: 'E-mail administrativo',
                      child: TextFormField(
                        controller: _email,
                        enabled: !_loading,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        validator: validateAdminEmail,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'Senha',
                      child: TextFormField(
                        controller: _password,
                        enabled: !_loading,
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.done,
                        validator: (value) =>
                            (value ?? '').isEmpty ? 'Senha obrigatória' : null,
                        onFieldSubmitted: (_) => _continue(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      style: adminButtonStyle(context),
                      onPressed: _loading ? null : _continue,
                      icon: const Icon(Icons.lock_outline, size: 18),
                      label: Text(_loading ? 'VERIFICANDO...' : 'Continuar'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'admin.orbita.edu · sessão própria\n'
                      'Não compartilhe login com o portal acadêmico',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(color: colors.text),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
