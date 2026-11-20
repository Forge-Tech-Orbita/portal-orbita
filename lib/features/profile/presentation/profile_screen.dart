import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/mock/student_mock.dart';
import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/student_id_card.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.pickPhoto, this.isWeb = kIsWeb});

  /// Permite substituir o seletor de imagens em testes.
  final PickProfilePhoto? pickPhoto;

  /// Biometria só pode ser ativada nos apps Android/iOS.
  final bool isWeb;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var _pushNotifications = true;
  late var _biometrics = !widget.isWeb;
  // shortcut: dados e foto ficam só no estado da tela, sem persistência.
  PersonalData _data = (
    phone: demoStudent.phone,
    personalEmail: demoStudent.personalEmail,
    postalCode: demoStudent.postalCode,
    address: demoStudent.address,
    photo: null,
  );

  Future<void> _edit() async {
    final data = await Navigator.of(context).push<PersonalData>(
      MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.editProfile),
        builder: (_) =>
            EditProfileScreen(initial: _data, pickPhoto: widget.pickPhoto),
      ),
    );
    if (!mounted || data == null) return;

    setState(() => _data = data);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Dados pessoais atualizados.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('CONTA', style: textTheme.labelMedium),
              const SizedBox(height: 6),
              StudentIdCard(
                student: demoStudent,
                compact: true,
                photo: _data.photo,
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (icon, label, value) in [
                        (Icons.badge_outlined, 'CPF', demoStudent.maskedCpf),
                        (
                          Icons.near_me_outlined,
                          'E-mail institucional',
                          demoStudent.email,
                        ),
                        (
                          Icons.person_outline,
                          'Telefone',
                          maskPhone(_data.phone),
                        ),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Icon(icon, size: 18, color: OrbitaTheme.muted),
                              const SizedBox(width: 10),
                              Expanded(
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar dados pessoais'),
              ),
              const SizedBox(height: 14),
              Text('PREFERÊNCIAS', style: textTheme.labelMedium),
              const SizedBox(height: 6),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Notificações push'),
                      value: _pushNotifications,
                      onChanged: (value) =>
                          setState(() => _pushNotifications = value),
                    ),
                    const SwitchListTile(
                      secondary: Icon(Icons.dark_mode_outlined),
                      title: Text('Modo escuro'),
                      subtitle: Text('Disponível quando o tema escuro existir'),
                      value: false,
                      onChanged: null,
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.fingerprint),
                      title: const Text('Biometria'),
                      subtitle: const Text('Somente no app Android/iOS'),
                      value: _biometrics,
                      onChanged: widget.isWeb
                          ? null
                          : (value) => setState(() => _biometrics = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: OrbitaTheme.terracotta,
                  side: const BorderSide(color: OrbitaTheme.terracotta),
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
