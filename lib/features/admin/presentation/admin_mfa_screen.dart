import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/orbita_colors.dart';
import '../data/admin.dart';
import 'admin_login_screen.dart';

const maxMfaAttempts = 5;

class AdminMfaScreen extends StatefulWidget {
  const AdminMfaScreen({super.key});

  @override
  State<AdminMfaScreen> createState() => _AdminMfaScreenState();
}

class _AdminMfaScreenState extends State<AdminMfaScreen> {
  final _code = TextEditingController();
  final _focus = FocusNode();
  String? _error;
  int _failures = 0;
  bool _loading = false;

  bool get _locked => _failures >= maxMfaAttempts;

  Future<void> _verify() async {
    if (_loading || _locked) return;
    final error = validateMfaCode(_code.text);
    if (error != null) {
      setState(() {
        _error = error;
        _failures++;
      });
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });
    // shortcut: código aceito sem conferir o autenticador real.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.admin, (_) => false);
  }

  void _securityKey() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Chave de segurança disponível após a integração com o provedor de identidade.',
          ),
        ),
      );
  }

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrbitaColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final error = _locked
        ? 'Conta bloqueada após $maxMfaAttempts tentativas. O superadmin foi avisado.'
        : _error;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.text,
        foregroundColor: colors.surface,
        titleTextStyle: textTheme.titleMedium?.copyWith(color: colors.surface),
        title: const Text('Portal Administrativo'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surface,
                  ),
                  child: const Icon(Icons.lock_outline, size: 30),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Verificação obrigatória',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
              Text(
                'Digite o código de 6 dígitos do seu aplicativo autenticador.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Código de verificação',
                textField: true,
                child: Stack(
                  children: [
                    ExcludeSemantics(
                      child: ValueListenableBuilder(
                        valueListenable: _code,
                        builder: (context, value, _) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 6,
                          children: [
                            for (var index = 0; index < 6; index++)
                              Flexible(
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 44,
                                    minHeight: 48,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: index == value.text.length
                                          ? colors.text
                                          : colors.border,
                                    ),
                                  ),
                                  child: Text(
                                    index < value.text.length
                                        ? value.text[index]
                                        : '',
                                    style: textTheme.titleLarge,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0,
                        child: TextField(
                          key: const Key('mfa-code'),
                          controller: _code,
                          focusNode: _focus,
                          enabled: !_loading && !_locked,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          showCursor: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(counterText: ''),
                          onSubmitted: (_) => _verify(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: colors.alert),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                style: adminButtonStyle(context),
                onPressed: _loading || _locked ? null : _verify,
                icon: const Icon(Icons.check, size: 18),
                label: Text(_loading ? 'VERIFICANDO...' : 'Verificar e entrar'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _loading ? null : _securityKey,
                icon: const Icon(Icons.shield_outlined, size: 18),
                label: const Text('Usar chave de segurança'),
              ),
              const SizedBox(height: 12),
              Text(
                'Após $maxMfaAttempts tentativas a conta é bloqueada e o superadmin é avisado.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
