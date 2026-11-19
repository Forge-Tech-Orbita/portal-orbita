import 'package:flutter/material.dart';

typedef PersonalData = ({String phone, String personalEmail});

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Formata telefone com DDD: `(11) 91234-5678` ou `(11) 1234-5678`.
String formatPhone(String digits) {
  final ddd = digits.substring(0, 2);
  final number = digits.substring(2);
  final split = number.length - 4;
  return '($ddd) ${number.substring(0, split)}-${number.substring(split)}';
}

String? validatePhone(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return 'Informe o telefone com DDD.';
  if (digits.length < 10 || digits.length > 11) {
    return 'Use DDD + número, com 10 ou 11 dígitos.';
  }
  return null;
}

String? validatePersonalEmail(String? value) {
  final email = (value ?? '').trim();
  if (email.isEmpty) return null;
  if (!_emailPattern.hasMatch(email)) return 'Informe um e-mail válido.';
  if (email.toLowerCase().endsWith('@orbita.edu')) {
    return 'Use um e-mail pessoal, não o institucional.';
  }
  return null;
}

class EditPersonalDataSheet extends StatefulWidget {
  const EditPersonalDataSheet({super.key, required this.initialPersonalEmail});

  final String initialPersonalEmail;

  @override
  State<EditPersonalDataSheet> createState() => _EditPersonalDataSheetState();
}

class _EditPersonalDataSheetState extends State<EditPersonalDataSheet> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  late final _personalEmail = TextEditingController(
    text: widget.initialPersonalEmail,
  );
  bool _saving = false;

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    // shortcut: atualização simulada, sem persistência; integrar cadastro em etapa própria.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    Navigator.of(context).pop<PersonalData>((
      phone: formatPhone(digits),
      personalEmail: _personalEmail.text.trim(),
    ));
  }

  @override
  void dispose() {
    _phone.dispose();
    _personalEmail.dispose();
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
                Text('Atualizar dados pessoais', style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Nome, CPF e e-mail institucional só podem ser alterados pela secretaria.',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phone,
                  enabled: !_saving,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Telefone com DDD',
                    hintText: '(11) 91234-5678',
                    border: OutlineInputBorder(),
                  ),
                  validator: validatePhone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _personalEmail,
                  enabled: !_saving,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'E-mail pessoal (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  validator: validatePersonalEmail,
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'SALVANDO...' : 'Salvar alterações'),
                ),
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
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
