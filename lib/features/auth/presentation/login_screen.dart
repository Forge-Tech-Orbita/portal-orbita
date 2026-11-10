import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/mock/student_mock.dart';
import '../../../core/theme/orbita_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registration = TextEditingController(text: demoStudent.registration);
  final _password = TextEditingController(text: '••••••••');
  bool _loading = false;

  Future<void> _login() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    // shortcut: acesso simulado sem verificar credenciais, integrar autenticação em etapa própria.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.main, (_) => false);
  }

  @override
  void dispose() {
    _registration.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(height: 16),
                    Center(
                      child: Semantics(
                        label: 'Símbolo orbital do Instituto Órbita',
                        image: true,
                        child: const CustomPaint(
                          size: Size.square(64),
                          painter: _OrbitMarkPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ÓRBITA',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const Text(
                      'ENSINO EM OUTRA ÓRBITA',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _registration,
                      enabled: !_loading,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Matrícula',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe a matrícula.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      enabled: !_loading,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Senha de acesso',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe a senha.'
                          : null,
                      onFieldSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _loading ? null : _login,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        _loading ? 'AUTENTICANDO...' : 'ENTRAR NO PORTAL',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _loading ? null : _login,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text(
                        'Acessar com biometria (simulada)',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'INSTITUTO ÓRBITA · SISTEMA ACADÊMICO v3.2\n'
                      'Demonstração local · sem autenticação real',
                      textAlign: TextAlign.center,
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

class _OrbitMarkPainter extends CustomPainter {
  const _OrbitMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    final paint = Paint()..color = OrbitaTheme.surface;
    canvas.drawCircle(Offset.zero, 30, paint);
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = OrbitaTheme.border;
    canvas.drawCircle(Offset.zero, 30, paint);

    for (final (angle, color) in [
      (0.0, OrbitaTheme.text),
      (math.pi / 3, OrbitaTheme.terracotta),
      (2 * math.pi / 3, OrbitaTheme.amber),
    ]) {
      canvas.save();
      canvas.rotate(angle);
      paint.color = color;
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 42, height: 18),
        paint,
      );
      canvas.restore();
    }

    paint
      ..style = PaintingStyle.fill
      ..color = OrbitaTheme.text;
    canvas.drawCircle(Offset.zero, 5.5, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitMarkPainter oldDelegate) => false;
}
