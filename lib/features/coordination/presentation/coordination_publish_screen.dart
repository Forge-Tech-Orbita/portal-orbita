import 'package:flutter/material.dart';

import '../../../core/models/learning_material.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/page_heading.dart';
import '../../../core/widgets/status_tag.dart';
import '../data/coordination.dart';
import '../data/coordination_mock.dart';

final _datePattern = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
final _timePattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

String? validateEventDate(String? value) {
  final match = _datePattern.firstMatch((value ?? '').trim());
  if (match == null) return 'Use o formato dd/mm/aaaa.';
  final day = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final year = int.parse(match[3]!);
  final date = DateTime(year, month, day);
  final valid = date.day == day && date.month == month && date.year == year;
  return valid ? null : 'Data inválida.';
}

String? validateEventTime(String? value) =>
    _timePattern.hasMatch((value ?? '').trim()) ? null : 'Use hh:mm.';

class CoordinationPublishScreen extends StatefulWidget {
  const CoordinationPublishScreen({
    super.key,
    required this.posts,
    required this.onPublished,
  });

  final List<CoursePost> posts;
  final ValueChanged<CoursePost> onPublished;

  @override
  State<CoordinationPublishScreen> createState() =>
      _CoordinationPublishScreenState();
}

class _CoordinationPublishScreenState extends State<CoordinationPublishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _date = TextEditingController();
  final _time = TextEditingController();
  final _place = TextEditingController();
  final _description = TextEditingController();
  var _kind = PostKind.event;
  var _audience = coordinationAudiences.first;
  var _askConfirmation = true;
  bool _sending = false;

  bool get _isEvent => _kind == PostKind.event;

  Future<void> _publish() async {
    if (_sending || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    // shortcut: publicação simulada no mural, sem envio real.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final now = DateTime.now();
    widget.onPublished(
      CoursePost(
        title: _title.text.trim(),
        kind: _kind,
        audience: _audience.audiences.first.toLowerCase(),
        date:
            '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}',
      ),
    );
    for (final controller in [_title, _date, _time, _place, _description]) {
      controller.clear();
    }
    setState(() => _sending = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${_kind.label} publicado no mural.')),
      );
  }

  @override
  void dispose() {
    for (final controller in [_title, _date, _time, _place, _description]) {
      controller.dispose();
    }
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
              overline: 'Mural do curso',
              title: 'Eventos e comunicados',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final kind in PostKind.values)
                  ChoiceChip(
                    label: Text(kind.label),
                    selected: kind == _kind,
                    onSelected: _sending
                        ? null
                        : (_) => setState(() => _kind = kind),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LabeledField(
              label: 'Para quem',
              child: DropdownButtonFormField<AudienceOption>(
                initialValue: _audience,
                isExpanded: true,
                items: [
                  for (final option in coordinationAudiences)
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
                validator: (value) => (value ?? '').trim().length < 5
                    ? 'Informe um título com ao menos 5 caracteres.'
                    : null,
              ),
            ),
            if (_isEvent) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Expanded(
                    child: LabeledField(
                      label: 'Data',
                      child: TextFormField(
                        controller: _date,
                        enabled: !_sending,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          hintText: 'dd/mm/aaaa',
                        ),
                        validator: validateEventDate,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LabeledField(
                      label: 'Horário',
                      child: TextFormField(
                        controller: _time,
                        enabled: !_sending,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(hintText: 'hh:mm'),
                        validator: validateEventTime,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LabeledField(
                label: 'Local',
                child: TextFormField(
                  controller: _place,
                  enabled: !_sending,
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Informe o local.' : null,
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.check),
                title: const Text('Pedir confirmação de presença'),
                value: _askConfirmation,
                onChanged: _sending
                    ? null
                    : (value) => setState(() => _askConfirmation = value),
              ),
            ],
            const SizedBox(height: 12),
            LabeledField(
              label: 'Descrição',
              child: TextFormField(
                controller: _description,
                enabled: !_sending,
                minLines: 2,
                maxLines: 5,
                validator: (value) => (value ?? '').trim().length < 10
                    ? 'Descreva com ao menos 10 caracteres.'
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _sending ? null : _publish,
              icon: const Icon(Icons.send_outlined, size: 18),
              label: Text(_sending ? 'PUBLICANDO...' : 'Publicar no mural'),
            ),
            const SizedBox(height: 16),
            Text('Publicados', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final post in widget.posts)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InfoCard(
                  icon: post.kind == PostKind.event
                      ? Icons.event_outlined
                      : Icons.campaign_outlined,
                  title: post.title,
                  subtitle:
                      '${post.kind.label} · ${post.audience} · ${post.date}',
                  trailing: StatusTag(
                    label: post.kind.label,
                    tone: post.kind == PostKind.event
                        ? TagTone.danger
                        : TagTone.info,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
