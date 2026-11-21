import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/mock/student_mock.dart';
import '../../auth/data/academic_session.dart';
import '../../../core/widgets/account_avatar.dart';
import '../../../core/theme/orbita_colors.dart';
import '../../../core/widgets/student_id_card.dart';
import 'edit_profile_screen.dart';
import 'widgets/theme_selector.dart';

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
  PersonalData? _localData;
  String? _dataUid;

  PersonalData get _data => _localData!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = AcademicSessionScope.maybeOf(context)?.profile;
    if (_localData == null || _dataUid != profile?.uid) {
      _dataUid = profile?.uid;
      final student = profile?.student ?? demoStudent;
      _localData = (
        phone: student.phone,
        personalEmail: student.personalEmail,
        postalCode: student.postalCode,
        address: student.address,
        photo: null,
      );
    }
  }

  Future<void> _edit() async {
    final student =
        AcademicSessionScope.maybeOf(context)?.profile?.student ?? demoStudent;
    final data = await Navigator.of(context).push<PersonalData>(
      MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.editProfile),
        builder: (_) => EditProfileScreen(
          initial: _data,
          pickPhoto: widget.pickPhoto,
          student: student,
        ),
      ),
    );
    if (!mounted || data == null) return;

    setState(() => _localData = data);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Dados pessoais atualizados.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final session = AcademicSessionScope.maybeOf(context);
    final profile = session?.profile;
    final student = profile?.student ?? demoStudent;
    final colors = OrbitaColors.of(context);
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
                student: student,
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
                        (Icons.badge_outlined, 'CPF', student.maskedCpf),
                        (
                          Icons.near_me_outlined,
                          'E-mail institucional',
                          student.email,
                        ),
                        (
                          Icons.person_outline,
                          'Telefone',
                          _data.phone.isEmpty
                              ? 'Não informado'
                              : maskPhone(_data.phone),
                        ),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Icon(icon, size: 18, color: colors.muted),
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
              if (profile != null) ...[
                Text(
                  '${student.institution} · ${profile.semester} · ${student.period}',
                ),
                Text('Curso: ${student.course} · vínculo não editável'),
                const Text(
                  'Dados pessoais, foto e preferências são locais; não são salvos no banco.',
                ),
              ],
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
              const SizedBox(height: 14),
              const ThemeSelector(),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => signOut(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.secondary,
                  side: BorderSide(color: colors.secondary),
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
