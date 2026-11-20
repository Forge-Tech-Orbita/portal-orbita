import 'package:flutter/material.dart';

import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/labeled_field.dart';
import '../data/support_tickets_mock.dart';

typedef NewTicketData = ({String category, String subject, String description});

class NewTicketScreen extends StatefulWidget {
  const NewTicketScreen({super.key});

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _description = TextEditingController();
  String? _category;
  bool _sending = false;

  Future<void> _submit() async {
    if (_sending || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    // shortcut: envio simulado, sem integração com sistema de chamados.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    Navigator.of(context).pop<NewTicketData>((
      category: _category!,
      subject: _subject.text.trim(),
      description: _description.text.trim(),
    ));
  }

  void _attach() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Anexos ficam disponíveis após a integração.'),
        ),
      );
  }

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo chamado')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Formulário simulado · protocolo gerado localmente',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Assunto',
                  child: DropdownButtonFormField<String>(
                    initialValue: _category,
                    isExpanded: true,
                    hint: const Text('Selecione o assunto'),
                    items: [
                      for (final category in supportTicketCategories)
                        DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                    ],
                    onChanged: _sending
                        ? null
                        : (value) => setState(() => _category = value),
                    validator: (value) =>
                        value == null ? 'Selecione o assunto.' : null,
                  ),
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Título',
                  child: TextFormField(
                    controller: _subject,
                    enabled: !_sending,
                    textInputAction: TextInputAction.next,
                    maxLength: 80,
                    decoration: const InputDecoration(counterText: ''),
                    validator: (value) => (value ?? '').trim().length < 5
                        ? 'Descreva o título com ao menos 5 caracteres.'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Descrição',
                  child: TextFormField(
                    controller: _description,
                    enabled: !_sending,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 500,
                    decoration: const InputDecoration(counterText: ''),
                    validator: (value) => (value ?? '').trim().length < 10
                        ? 'Detalhe a solicitação com ao menos 10 caracteres.'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _sending ? null : _attach,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            color: OrbitaTheme.muted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Anexar arquivo'),
                                Text(
                                  'PDF ou imagem, até 5 MB',
                                  style: textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.add, color: OrbitaTheme.primary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _sending ? null : _submit,
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: Text(_sending ? 'ENVIANDO...' : 'Enviar chamado'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _sending
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
