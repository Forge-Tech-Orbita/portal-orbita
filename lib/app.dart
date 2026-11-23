import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'core/models/app_notification.dart';
import 'core/theme/orbita_theme_controller.dart';
import 'features/admin/presentation/admin_login_screen.dart';
import 'features/admin/presentation/admin_mfa_screen.dart';
import 'features/admin/presentation/admin_shell.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/data/academic_session.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/grades/data/grades_repository.dart';
import 'features/profile/presentation/course_selection_screen.dart';
import 'features/coordination/data/coordination_mock.dart';
import 'features/coordination/presentation/coordination_shell.dart';
import 'features/financial/presentation/financial_screen.dart';
import 'features/financial/presentation/payment_screen.dart';
import 'features/library/presentation/catalog_screen.dart';
import 'features/library/presentation/library_screen.dart';
import 'features/materials/presentation/materials_screen.dart';
import 'features/materials/presentation/new_material_screen.dart';
import 'features/navigation/presentation/main_navigation_screen.dart';
import 'features/notices/presentation/notices_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/professor/data/professor_mock.dart';
import 'features/professor/presentation/professor_shell.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/support/data/support_ticket.dart';
import 'features/support/presentation/new_ticket_screen.dart';
import 'features/support/presentation/support_screen.dart';
import 'features/support/presentation/ticket_sent_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key, this.authRepository, this.gradesRepository});

  final AuthRepository? authRepository;
  final GradesRepository? gradesRepository;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final _gradesRepository =
      widget.gradesRepository ?? FirebaseGradesRepository();
  var _themeController = OrbitaThemeController();
  late final _session = AcademicSession(
    widget.authRepository ?? FirebaseAuthRepository(),
  );
  String? _themeUid;

  @override
  void initState() {
    super.initState();
    _session.addListener(_resetUserTheme);
  }

  void _resetUserTheme() {
    final uid = _session.profile?.uid;
    if (uid == _themeUid) return;
    _themeUid = uid;
    final previous = _themeController;
    setState(() => _themeController = OrbitaThemeController());
    previous.dispose();
  }

  @override
  void dispose() {
    _session.removeListener(_resetUserTheme);
    _themeController.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // O app inteiro é reconstruído com o novo tema quando a escolha muda.
    return AcademicSessionScope(
      session: _session,
      child: OrbitaThemeScope(
        controller: _themeController,
        child: ListenableBuilder(
          listenable: Listenable.merge([_themeController, _session]),
          builder: (context, _) => MaterialApp(
            key: ValueKey(_session.navigationEpoch),
            title: 'Portal Órbita',
            theme: _themeController.themeData,
            initialRoute:
                _session.profile?.courseId != null && !_session.loading
                ? AppRoutes.main
                : AppRoutes.login,
            onGenerateRoute: _onGenerateRoute,
            onGenerateInitialRoutes: (route) => [
              _onGenerateRoute(RouteSettings(name: route)),
            ],
          ),
        ),
      ),
    );
  }

  Route<void> _onGenerateRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    final sessionReady =
        _session.profile?.courseId != null && !_session.loading;
    final protectedRoute = {
      AppRoutes.main,
      AppRoutes.financial,
      AppRoutes.payment,
      AppRoutes.library,
      AppRoutes.catalog,
      AppRoutes.materials,
      AppRoutes.notices,
      AppRoutes.notifications,
      AppRoutes.support,
      AppRoutes.newTicket,
      AppRoutes.ticketSent,
      AppRoutes.profile,
      AppRoutes.editProfile,
    }.contains(settings.name);
    if (protectedRoute && !sessionReady) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => _entry(),
      );
    }
    final screen = switch (settings.name) {
      AppRoutes.login => _entry(),
      AppRoutes.main => MainNavigationScreen(
        gradesRepository: _gradesRepository,
      ),
      AppRoutes.financial => const FinancialScreen(),
      AppRoutes.payment => PaymentScreen(
        initialMethod: arguments is PaymentMethod
            ? arguments
            : PaymentMethod.pix,
      ),
      AppRoutes.library => const LibraryScreen(),
      AppRoutes.catalog => CatalogScreen(
        initial: arguments is CatalogQuery ? arguments : const CatalogQuery(),
      ),
      AppRoutes.materials => const MaterialsScreen(),
      AppRoutes.notices => const NoticesScreen(),
      AppRoutes.notifications => NotificationsScreen(
        notifications: arguments is ValueNotifier<List<AppNotification>>
            ? arguments
            : null,
      ),
      AppRoutes.support => const SupportScreen(),
      AppRoutes.newTicket => const NewTicketScreen(),
      AppRoutes.ticketSent when arguments is SupportTicket => TicketSentScreen(
        ticket: arguments,
      ),
      AppRoutes.profile => const ProfileScreen(),
      AppRoutes.professor => const ProfessorShell(),
      AppRoutes.professorNewMaterial => NewMaterialScreen(
        audienceLabel: 'Para qual turma',
        author: professorName,
        audienceOptions: [
          for (final teachingClass in teachingClasses)
            (
              label: '${teachingClass.code} · ${teachingClass.subject}',
              audiences: [teachingClass.code],
            ),
        ],
      ),
      AppRoutes.coordination => const CoordinationShell(),
      AppRoutes.coordinationNewMaterial => const NewMaterialScreen(
        audienceLabel: 'Para quem',
        author: 'Coordenação',
        audienceOptions: coordinationAudiences,
      ),
      AppRoutes.adminLogin => const AdminLoginScreen(),
      AppRoutes.adminMfa => const AdminMfaScreen(),
      AppRoutes.admin => const AdminShell(),
      _ => const Scaffold(
        body: SafeArea(child: Center(child: Text('Rota não encontrada'))),
      ),
    };

    return MaterialPageRoute<void>(settings: settings, builder: (_) => screen);
  }

  Widget _entry() {
    if (_session.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_session.profile == null) return const LoginScreen();
    if (_session.profile!.courseId == null) {
      return const CourseSelectionScreen();
    }
    return MainNavigationScreen(gradesRepository: _gradesRepository);
  }
}
