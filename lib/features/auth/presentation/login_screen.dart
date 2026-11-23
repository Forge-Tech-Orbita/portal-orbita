import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/institution_catalog.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/orbit_logo.dart';
import '../data/academic_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registration = TextEditingController();
  final _password = TextEditingController();
  String _institution = institutions.keys.first;

  Future<void> _login() async {
    final session = AcademicSessionScope.maybeOf(context);
    if (session == null ||
        session.loading ||
        !_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    final password = _password.text;
    _password.clear();
    await session.signIn(_institution, _registration.text.trim(), password);
  }

  @override
  void dispose() {
    _registration.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = AcademicSessionScope.maybeOf(context);
    final busy = session?.loading ?? false;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
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
                      const Text('Acesso do aluno · Firebase'),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _institution,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Instituição',
                        ),
                        items: [
                          for (final entry in institutions.entries)
                            DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value.name),
                            ),
                        ],
                        onChanged: busy
                            ? null
                            : (value) => setState(() => _institution = value!),
                      ),
                      const SizedBox(height: 14),
                      LabeledField(
                        label: 'Matrícula',
                        child: TextFormField(
                          controller: _registration,
                          enabled: !busy,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Digite sua matrícula',
                          ),
                          validator: (value) {
                            try {
                              technicalEmail(
                                _institution,
                                (value ?? '').trim(),
                              );
                              return null;
                            } on FormatException {
                              return 'Informe uma matrícula numérica de até 20 dígitos.';
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      LabeledField(
                        label: 'Senha de acesso',
                        child: TextFormField(
                          controller: _password,
                          enabled: !busy,
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Digite sua senha',
                          ),
                          validator: (value) => (value ?? '').isEmpty
                              ? 'Senha obrigatória'
                              : null,
                          onFieldSubmitted: (_) => _login(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (session?.error case final String error)
                        Text(error, semanticsLabel: 'Erro: $error'),
                      FilledButton.icon(
                        onPressed: busy ? null : _login,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          busy ? 'AUTENTICANDO...' : 'ENTRAR NO PORTAL',
                        ),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => showDialog<void>(
                                context: context,
                                builder: (context) => const AlertDialog(
                                  title: Text('Recuperação de acesso'),
                                  content: Text(
                                    'Solicite a redefinição ao responsável pelas contas de demonstração.',
                                  ),
                                ),
                              ),
                        child: const Text('Esqueci minha senha'),
                      ),
                      const Divider(),
                      const Text(
                        'Protótipos demonstrativos · sem autenticação',
                      ),
                      for (final entry in const [
                        ('Professor', AppRoutes.professor),
                        ('Coordenação', AppRoutes.coordination),
                      ])
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => Navigator.of(context).pushNamed(entry.$2),
                          child: Text('Demonstração: ${entry.$1}'),
                        ),
                      if (session?.error != null)
                        TextButton(
                          onPressed: busy ? null : session?.signOut,
                          child: const Text(
                            'Encerrar sessão e tentar novamente',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
