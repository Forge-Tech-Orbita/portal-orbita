import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/mock/student_mock.dart';
import '../../../core/theme/orbita_colors.dart';
import '../../../core/widgets/student_id_card.dart';
import 'widgets/edit_personal_data_sheet.dart';
import 'widgets/theme_selector.dart';

typedef PickProfilePhoto = Future<XFile?> Function(ImageSource source);

Future<XFile?> _pickWithImagePicker(ImageSource source) {
  return ImagePicker().pickImage(
    source: source,
    maxWidth: 512,
    maxHeight: 512,
    imageQuality: 85,
  );
}

enum _PhotoAction { gallery, camera, remove }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.pickPhoto});

  /// Permite substituir o seletor de imagens em testes.
  final PickProfilePhoto? pickPhoto;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var _pushNotifications = true;
  var _darkMode = true;
  var _facialBiometrics = false;
  // shortcut: dados e foto ficam só no estado da tela, sem persistência.
  var _phone = demoStudent.maskedPhone;
  var _personalEmail = '';
  ImageProvider? _photo;

  Future<void> _changePhoto() async {
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
                leading: Icon(
                  Icons.delete_outline,
                  color: OrbitaColors.of(context).alert,
                ),
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

  Future<void> _editPersonalData() async {
    final data = await showModalBottomSheet<PersonalData>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          EditPersonalDataSheet(initialPersonalEmail: _personalEmail),
    );
    if (!mounted || data == null) return;

    setState(() {
      _phone = data.phone;
      _personalEmail = data.personalEmail;
    });
    _showMessage('Dados pessoais atualizados.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = OrbitaColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('CONTA', style: textTheme.labelMedium),
              const SizedBox(height: 8),
              StudentIdCard(student: demoStudent, compact: true, photo: _photo),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _changePhoto,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(
                    _photo == null ? 'Adicionar foto' : 'Alterar foto',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                color: colors.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (icon, label, value) in [
                        (Icons.badge_outlined, 'CPF', demoStudent.maskedCpf),
                        (
                          Icons.mail_outline,
                          'E-mail institucional',
                          demoStudent.email,
                        ),
                        (Icons.phone_outlined, 'Telefone', _phone),
                        (
                          Icons.alternate_email,
                          'E-mail pessoal',
                          _personalEmail.isEmpty
                              ? 'Não informado'
                              : _personalEmail,
                        ),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(icon, size: 18, color: colors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  spacing: 12,
                                  runSpacing: 4,
                                  children: [
                                    Text(label, style: textTheme.titleSmall),
                                    Text(value),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _editPersonalData,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar dados pessoais'),
              ),
              TextButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.support),
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('Corrigir nome ou CPF com o suporte'),
              ),
              const SizedBox(height: 16),
              const ThemeSelector(),
              const SizedBox(height: 16),
              Text(
                'Preferências demonstrativas · efeito apenas visual nesta tela',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                color: colors.surface,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(
                        Icons.notifications_outlined,
                        color: colors.primary,
                      ),
                      title: const Text('Notificações push'),
                      value: _pushNotifications,
                      onChanged: (value) =>
                          setState(() => _pushNotifications = value),
                    ),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.dark_mode_outlined,
                        color: colors.primary,
                      ),
                      title: const Text('Modo escuro'),
                      value: _darkMode,
                      onChanged: (value) => setState(() => _darkMode = value),
                    ),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.person_outline,
                        color: colors.primary,
                      ),
                      title: const Text('Biometria facial'),
                      value: _facialBiometrics,
                      onChanged: (value) =>
                          setState(() => _facialBiometrics = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.alert,
                  side: BorderSide(color: colors.alert),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Encerrar sessão'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
