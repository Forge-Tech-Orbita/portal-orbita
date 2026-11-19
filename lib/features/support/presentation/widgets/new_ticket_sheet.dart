import 'package:flutter/material.dart';

import '../../data/support_tickets_mock.dart';

typedef NewTicketData = ({
  String category,
  String subject,
  String description,
});

class NewTicketSheet extends StatefulWidget {
  const NewTicketSheet({super.key});

  @override
  State<NewTicketSheet> createState() => _NewTicketSheetState();
}

class _NewTicketSheetState extends State<NewTicketSheet> {
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

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Novo chamado', style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'O chamado é simulado e aparece na aba Equipe de suporte.',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final category in supportTicketCategories)
                      DropdownMenuItem(value: category, child: Text(category)),
                  ],
                  onChanged: _sending
                      ? null
                      : (value) => setState(() => _category = value),
                  validator: (value) =>
                      value == null ? 'Selecione a categoria.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subject,
                  enabled: !_sending,
                  textInputAction: TextInputAction.next,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Assunto',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value ?? '').trim().length < 5
                      ? 'Descreva o assunto com ao menos 5 caracteres.'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  enabled: !_sending,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value ?? '').trim().length < 10
                      ? 'Detalhe a solicitação com ao menos 10 caracteres.'
                      : null,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _sending ? null : _submit,
                  child: Text(_sending ? 'ENVIANDO...' : 'Enviar chamado'),
                ),
                TextButton(
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
