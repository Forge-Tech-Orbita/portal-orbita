import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/orbita_colors.dart';
import '../data/support_ticket.dart';

class TicketSentScreen extends StatelessWidget {
  const TicketSentScreen({super.key, required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final colors = OrbitaColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Suporte')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(alpha: 0.14),
                  ),
                  child: Icon(Icons.check, size: 32, color: colors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Chamado enviado',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
              Text(
                'A secretaria responde em até 2 dias úteis.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      for (final (label, value) in [
                        ('Protocolo', ticket.protocol),
                        ('Assunto', ticket.category),
                        ('Status', ticket.status.label),
                        ('Aberto em', ticket.openedAt),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 12,
                            runSpacing: 4,
                            children: [Text(label), Text(value)],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar ao suporte'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () =>
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(AppRoutes.main, (_) => false),
                child: const Text('Ir para o início'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
