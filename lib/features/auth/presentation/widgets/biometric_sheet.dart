import 'package:flutter/material.dart';

import '../../../../core/theme/orbita_theme.dart';

/// Confirmação biométrica simulada; retorna `true` quando aprovada.
class BiometricSheet extends StatelessWidget {
  const BiometricSheet({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: OrbitaTheme.primary.withValues(alpha: 0.14),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  size: 34,
                  color: OrbitaTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Confirme sua identidade',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Toque no sensor ou olhe para a câmera para entrar como $name.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Simular leitura aprovada'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Usar matrícula e senha'),
            ),
            const SizedBox(height: 12),
            Text(
              'Biometria só existe no app Android/iOS; na Web o botão fica oculto.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
