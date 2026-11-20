import 'package:flutter/material.dart';

import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/page_heading.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/professor.dart';
import '../data/professor_mock.dart';

String _today() {
  final now = DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}/'
      '${now.month.toString().padLeft(2, '0')}';
}

class ProfessorNoticeScreen extends StatefulWidget {
  const ProfessorNoticeScreen({
    super.key,
    required this.notices,
    required this.onPublished,
  });

  final List<ClassNotice> notices;
  final ValueChanged<ClassNotice> onPublished;

  @override
  State<ProfessorNoticeScreen> createState() => _ProfessorNoticeScreenState();
}

class _ProfessorNoticeScreenState extends State<ProfessorNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _message = TextEditingController();
  var _classCode = teachingClasses.first.code;
  var _notify = true;
  bool _sending = false;

  Future<void> _publish() async {
    if (_sending || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    // shortcut: publicação simulada, sem envio real aos alunos.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    widget.onPublished(
      ClassNotice(
        title: _title.text.trim(),
        classCode: _classCode,
        date: _today(),
        readBy: 0,
      ),
    );
    _formKey.currentState!.reset();
    _title.clear();
    _message.clear();
    setState(() => _sending = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _notify
                ? 'Comunicado publicado para $_classCode e alunos notificados.'
                : 'Comunicado publicado para $_classCode.',
          ),
        ),
      );
  }

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeading(
              title: 'Comunicado',
              subtitle: 'Enviado só para turmas vinculadas a você',
            ),
            const SizedBox(height: 12),
            LabeledField(
              label: 'Turma',
              child: DropdownButtonFormField<String>(
                initialValue: _classCode,
                isExpanded: true,
                items: [
                  for (final teachingClass in teachingClasses)
                    DropdownMenuItem(
                      value: teachingClass.code,
                      child: Text(
                        '${teachingClass.code} · ${teachingClass.subject}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: _sending
                    ? null
                    : (value) => setState(() => _classCode = value!),
              ),
            ),
            const SizedBox(height: 12),
            LabeledField(
              label: 'Título',
              child: TextFormField(
                controller: _title,
                enabled: !_sending,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Ex.: Entrega do projeto prorrogada',
                ),
                validator: (value) => (value ?? '').trim().length < 5
                    ? 'Informe um título com ao menos 5 caracteres.'
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            LabeledField(
              label: 'Mensagem',
              child: TextFormField(
                controller: _message,
                enabled: !_sending,
                minLines: 3,
                maxLines: 6,
                validator: (value) => (value ?? '').trim().length < 10
                    ? 'Escreva a mensagem com ao menos 10 caracteres.'
                    : null,
              ),
            ),
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
            FilledButton.icon(
              onPressed: _sending ? null : _publish,
              icon: const Icon(Icons.send_outlined, size: 18),
              label: Text(_sending ? 'PUBLICANDO...' : 'Publicar comunicado'),
            ),
            const SizedBox(height: 16),
            Text('Enviados', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final notice in widget.notices)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InfoCard(
                  icon: Icons.campaign_outlined,
                  title: notice.title,
                  subtitle:
                      '${notice.classCode} · ${notice.date} · lido por ${notice.readBy}',
                  trailing: const StatusTag(
                    label: 'Publicado',
                    tone: TagTone.success,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
