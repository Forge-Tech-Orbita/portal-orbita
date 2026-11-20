import 'package:flutter/material.dart';

import '../../../core/models/learning_material.dart';
import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/labeled_field.dart';

final _urlPattern = RegExp(
  r'^https?://[^\s/$.?#].[^\s]*$',
  caseSensitive: false,
);

String? validateMaterialUrl(String? value) {
  final url = (value ?? '').trim();
  if (url.isEmpty) return 'Informe o endereço do link.';
  return _urlPattern.hasMatch(url)
      ? null
      : 'Use um link começando com http(s)://';
}

class NewMaterialScreen extends StatefulWidget {
  const NewMaterialScreen({
    super.key,
    required this.audienceLabel,
    required this.audienceOptions,
    required this.author,
  });

  /// "Para qual turma" (professor) ou "Para quem" (coordenação).
  final String audienceLabel;
  final List<AudienceOption> audienceOptions;
  final String author;

  @override
  State<NewMaterialScreen> createState() => _NewMaterialScreenState();
}

class _NewMaterialScreenState extends State<NewMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _url = TextEditingController();
  final _reason = TextEditingController();
  var _kind = MaterialKind.pdf;
  late var _audience = widget.audienceOptions.first;
  var _notify = true;
  bool _sending = false;

  void _chooseFile() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Envio de arquivos disponível após a integração; '
            'a publicação fica registrada como demonstração.',
          ),
        ),
      );
  }

  Future<void> _publish() async {
    if (_sending || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    // shortcut: publicação simulada, sem armazenamento de arquivos.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final reason = _reason.text.trim();
    final details = [
      widget.author,
      if (_kind == MaterialKind.link) Uri.tryParse(_url.text.trim())?.host,
      reason.isEmpty ? _audience.label : reason,
    ].whereType<String>().where((part) => part.isNotEmpty).join(' · ');

    Navigator.of(context).pop<PublishedMaterial>((
      material: LearningMaterial(
        id: 'new-${DateTime.now().microsecondsSinceEpoch}',
        title: _title.text.trim(),
        details: details,
        kind: _kind,
        audiences: _audience.audiences,
      ),
      notify: _notify,
    ));
  }

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo material')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final (kind, label) in const [
                      (MaterialKind.pdf, 'Livro em PDF'),
                      (MaterialKind.link, 'Link recomendado'),
                    ])
                      ChoiceChip(
                        label: Text(label),
                        selected: _kind == kind,
                        onSelected: _sending
                            ? null
                            : (_) => setState(() => _kind = kind),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: widget.audienceLabel,
                  child: DropdownButtonFormField<AudienceOption>(
                    initialValue: _audience,
                    isExpanded: true,
                    items: [
                      for (final option in widget.audienceOptions)
                        DropdownMenuItem(
                          value: option,
                          child: Text(
                            option.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: _sending
                        ? null
                        : (value) => setState(() => _audience = value!),
                  ),
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Título',
                  child: TextFormField(
                    controller: _title,
                    enabled: !_sending,
                    textInputAction: TextInputAction.next,
                    validator: (value) => (value ?? '').trim().length < 3
                        ? 'Informe o título do material.'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                if (_kind == MaterialKind.pdf)
                  Material(
                    color: OrbitaTheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: OrbitaTheme.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _sending ? null : _chooseFile,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.upload_outlined,
                              color: OrbitaTheme.primary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Escolher arquivo PDF',
                              style: textTheme.bodyMedium?.copyWith(
                                color: OrbitaTheme.primary,
                              ),
                            ),
                            Text(
                              'Até 20 MB · somente PDF',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  LabeledField(
                    label: 'Endereço do link',
                    child: TextFormField(
                      controller: _url,
                      enabled: !_sending,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      decoration: const InputDecoration(hintText: 'https://'),
                      validator: validateMaterialUrl,
                    ),
                  ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Por que recomendar? (opcional)',
                  child: TextFormField(
                    controller: _reason,
                    enabled: !_sending,
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notificar alunos'),
                  subtitle: const Text('Aparece em Notificações do aluno'),
                  value: _notify,
                  onChanged: _sending
                      ? null
                      : (value) => setState(() => _notify = value),
                ),
                Text(
                  'Envie só material com direito de distribuição '
                  '(domínio público, licença aberta ou autorizado).',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _sending ? null : _publish,
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: Text(_sending ? 'PUBLICANDO...' : 'Publicar material'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
