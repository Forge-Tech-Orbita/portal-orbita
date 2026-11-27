import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/mock/student_mock.dart';
import '../../../core/models/student.dart';
import '../../../core/theme/orbita_colors.dart';
import '../../../core/widgets/labeled_field.dart';

typedef PersonalData = ({
  String phone,
  String personalEmail,
  String postalCode,
  String address,
  ImageProvider? photo,
});

typedef PickProfilePhoto = Future<XFile?> Function(ImageSource source);

Future<XFile?> _pickWithImagePicker(ImageSource source) {
  return ImagePicker().pickImage(
    source: source,
    maxWidth: 512,
    maxHeight: 512,
    imageQuality: 85,
  );
}

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Formata telefone com DDD: `(11) 91234-5678` ou `(11) 1234-5678`.
String formatPhone(String digits) {
  final ddd = digits.substring(0, 2);
  final number = digits.substring(2);
  final split = number.length - 4;
  return '($ddd) ${number.substring(0, split)}-${number.substring(split)}';
}

/// Oculta os dígitos centrais: `(11) 98765-4521` vira `(11) 9••••-4521`.
String maskPhone(String formatted) {
  final match = RegExp(r'^(\(\d{2}\) \d)(\d+)(-\d{4})$').firstMatch(formatted);
  if (match == null) return formatted;
  return '${match[1]}${'•' * match[2]!.length}${match[3]}';
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

String? validatePostalCode(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  return digits.length == 8 ? null : 'O CEP tem 8 dígitos.';
}

String formatPostalCode(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 8) return value.trim();
  return '${digits.substring(0, 5)}-${digits.substring(5)}';
}

enum _PhotoAction { gallery, camera, remove }

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.initial,
    this.pickPhoto,
    this.student = demoStudent,
    this.onSave,
  });

  /// Persiste os dados; sem ela, a atualização é apenas simulada.
  final Future<void> Function(PersonalData data)? onSave;

  final Student student;

  final PersonalData initial;

  /// Permite substituir o seletor de imagens em testes.
  final PickProfilePhoto? pickPhoto;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _phone = TextEditingController(text: widget.initial.phone);
  late final _personalEmail = TextEditingController(
    text: widget.initial.personalEmail,
  );
  late final _postalCode = TextEditingController(
    text: widget.initial.postalCode,
  );
  late final _address = TextEditingController(text: widget.initial.address);
  late ImageProvider? _photo = widget.initial.photo;
  bool _saving = false;

  Future<void> _changePhoto() async {
    final colors = OrbitaColors.of(context);
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.of(context).pop(_PhotoAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.of(context).pop(_PhotoAction.camera),
            ),
            if (_photo != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: colors.alert),
                title: const Text('Remover foto'),
                onTap: () => Navigator.of(context).pop(_PhotoAction.remove),
              ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;

    if (action == _PhotoAction.remove) {
      setState(() => _photo = null);
      _showMessage('Foto de perfil removida.');
      return;
    }

    final pick = widget.pickPhoto ?? _pickWithImagePicker;
    try {
      final source = action == _PhotoAction.camera
          ? ImageSource.camera
          : ImageSource.gallery;
      final file = await pick(source);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _photo = MemoryImage(bytes));
      _showMessage('Foto de perfil atualizada.');
    } catch (_) {
      if (!mounted) return;
      _showMessage(
        'Não foi possível carregar a foto. Verifique as permissões.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    final data = (
      phone: formatPhone(digits),
      personalEmail: _personalEmail.text.trim(),
      postalCode: formatPostalCode(_postalCode.text),
      address: _address.text.trim(),
      photo: _photo,
    );
    try {
      final onSave = widget.onSave;
      if (onSave == null) {
        // shortcut: sem sessão (demonstração), a atualização é simulada.
        await Future<void>.delayed(const Duration(milliseconds: 900));
      } else {
        await onSave(data);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('Não foi possível salvar os dados. Tente novamente.');
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop<PersonalData>(data);
  }

  @override
  void dispose() {
    _phone.dispose();
    _personalEmail.dispose();
    _postalCode.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrbitaColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final photo = _photo;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar dados')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Nome, CPF e matrícula só mudam pela secretaria',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary.withValues(alpha: 0.08),
                        border: Border.all(color: colors.primary, width: 1.5),
                        image: photo == null
                            ? null
                            : DecorationImage(image: photo, fit: BoxFit.cover),
                      ),
                      child: photo == null
                          ? Icon(
                              Icons.person_outline,
                              size: 30,
                              color: colors.primary,
                            )
                          : null,
                    ),
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _changePhoto,
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: Text(
                        photo == null ? 'Adicionar foto' : 'Trocar foto',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: 'Nome',
                  child: TextFormField(
                    initialValue: widget.student.name,
                    enabled: false,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.support),
                    child: const Text('Corrigir nome ou CPF com o suporte'),
                  ),
                ),
                LabeledField(
                  label: 'E-mail pessoal',
                  child: TextFormField(
                    controller: _personalEmail,
                    enabled: !_saving,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    validator: validatePersonalEmail,
                  ),
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Telefone',
                  child: TextFormField(
                    controller: _phone,
                    enabled: !_saving,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: '(11) 91234-5678',
                    ),
                    validator: validatePhone,
                  ),
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'CEP',
                  child: TextFormField(
                    controller: _postalCode,
                    enabled: !_saving,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: validatePostalCode,
                  ),
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Endereço',
                  child: TextFormField(
                    controller: _address,
                    enabled: !_saving,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.check),
                  label: Text(_saving ? 'SALVANDO...' : 'Salvar alterações'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
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
