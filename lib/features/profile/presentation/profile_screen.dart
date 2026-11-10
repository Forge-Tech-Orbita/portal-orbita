import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/mock/student_mock.dart';
import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/student_id_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var _pushNotifications = true;
  var _darkMode = true;
  var _facialBiometrics = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
              const StudentIdCard(student: demoStudent, compact: true),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                color: OrbitaTheme.surface,
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
                        (
                          Icons.phone_outlined,
                          'Telefone',
                          demoStudent.maskedPhone,
                        ),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(icon, size: 18, color: OrbitaTheme.primary),
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
              const SizedBox(height: 16),
              Text(
                'Preferências demonstrativas · efeito apenas visual nesta tela',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                color: OrbitaTheme.surface,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(
                        Icons.notifications_outlined,
                        color: OrbitaTheme.primary,
                      ),
                      title: const Text('Notificações push'),
                      value: _pushNotifications,
                      onChanged: (value) =>
                          setState(() => _pushNotifications = value),
                    ),
                    SwitchListTile(
                      secondary: const Icon(
                        Icons.dark_mode_outlined,
                        color: OrbitaTheme.primary,
                      ),
                      title: const Text('Modo escuro'),
                      value: _darkMode,
                      onChanged: (value) => setState(() => _darkMode = value),
                    ),
                    SwitchListTile(
                      secondary: const Icon(
                        Icons.person_outline,
                        color: OrbitaTheme.primary,
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
                  foregroundColor: OrbitaTheme.alert,
                  side: const BorderSide(color: OrbitaTheme.alert),
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
