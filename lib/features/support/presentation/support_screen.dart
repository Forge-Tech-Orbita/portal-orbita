import 'package:flutter/material.dart';

import '../../../core/theme/orbita_theme.dart';

const _supportFaqs = [
  ('Como emito a 2ª via do boleto?', 'Acesse Financeiro → Gerar 2ª via.'),
  (
    'Como solicito o histórico escolar?',
    'Abra um chamado na Central de Suporte.',
  ),
  ('Onde vejo minha frequência?', 'Acesse Notas → detalhes da disciplina.'),
];

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Central de suporte')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Atendimento demonstrativo · sem abertura real de chamados',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                color: OrbitaTheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'FALE COM A SECRETARIA',
                        style: textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Abra um chamado para dúvidas sobre matrícula, documentos, aproveitamento de disciplinas ou requerimentos.',
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Recurso demonstrativo, sem integração',
                                ),
                              ),
                            ),
                        child: const Text('Abrir novo chamado'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Perguntas frequentes', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                color: OrbitaTheme.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (question, answer) in _supportFaqs)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(question, style: textTheme.titleSmall),
                              const SizedBox(height: 4),
                              Text(answer),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
