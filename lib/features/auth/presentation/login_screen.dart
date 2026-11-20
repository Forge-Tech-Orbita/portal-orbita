import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/mock/demo_accounts.dart';
import '../../../core/mock/student_mock.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/orbit_logo.dart';
import '../../../core/widgets/status_tag.dart';
import 'widgets/biometric_sheet.dart';

const maxLoginAttempts = 5;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.biometricsAvailable = !kIsWeb});

  /// Biometria existe só nos apps Android/iOS.
  final bool biometricsAvailable;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registration = TextEditingController(text: demoStudent.registration);
  final _password = TextEditingController(text: '••••••••');
  bool _loading = false;
  int _failedAttempts = 0;

  bool get _blocked => _failedAttempts >= maxLoginAttempts;

  Future<void> _login() async {
    if (_loading || _blocked || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    // shortcut: acesso simulado por contas fixas, integrar autenticação em etapa própria.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final role = roleForRegistration(_registration.text);
    if (role == null) {
      setState(() {
        _loading = false;
        _failedAttempts++;
      });
      return;
    }
    _enter(role);
  }

  void _enter(AcademicRole role) {
    Navigator.of(context).pushNamedAndRemoveUntil(role.homeRoute, (_) => false);
  }

  Future<void> _biometrics() async {
    final approved = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => BiometricSheet(name: demoStudent.shortName),
    );
    if (!mounted || approved != true) return;

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    _enter(AcademicRole.student);
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'A redefinição de senha é feita pela secretaria acadêmica.',
          ),
        ),
      );
  }

  @override
  void dispose() {
    _registration.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final remaining = maxLoginAttempts - _failedAttempts;

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
                    const OrbitLogo(),
                    const SizedBox(height: 28),
                    if (_failedAttempts > 0) ...[
                      InfoBanner(
                        tone: TagTone.danger,
                        title: _blocked
                            ? 'Acesso bloqueado temporariamente'
                            : 'Matrícula ou senha incorretos',
                        message: _blocked
                            ? 'Procure a secretaria para liberar o acesso.'
                            : 'Restam $remaining tentativas antes do bloqueio temporário.',
                      ),
                      const SizedBox(height: 16),
                    ],
                    LabeledField(
                      label: 'Matrícula',
                      child: TextFormField(
                        controller: _registration,
                        enabled: !_loading,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Digite sua matrícula',
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Matrícula obrigatória'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'Senha de acesso',
                      child: TextFormField(
                        controller: _password,
                        enabled: !_loading,
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          hintText: 'Digite sua senha',
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Senha obrigatória'
                            : null,
                        onFieldSubmitted: (_) => _login(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _loading || _blocked ? null : _login,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        _loading ? 'AUTENTICANDO...' : 'ENTRAR NO PORTAL',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.biometricsAvailable && _failedAttempts == 0)
                      TextButton(
                        onPressed: _loading ? null : _biometrics,
                        child: const Text('Acessar com biometria'),
                      ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _forgotPassword,
                      child: Text(
                        'Esqueci minha senha',
                        style: textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'INSTITUTO ÓRBITA · SISTEMA ACADÊMICO v3.2\n'
                      'Acesso acadêmico: aluno, professor e coordenação',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
