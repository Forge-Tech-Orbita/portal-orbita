import '../constants/app_routes.dart';

enum AcademicRole {
  student(AppRoutes.main),
  professor(AppRoutes.professor),
  coordination(AppRoutes.coordination);

  const AcademicRole(this.homeRoute);

  /// Rota inicial da casca de navegação de cada perfil.
  final String homeRoute;
}

// shortcut: contas fixas de demonstração, substituir pela autenticação real.
const demoAccounts = {
  '2023104567': AcademicRole.student,
  'P2019042': AcademicRole.professor,
  'C2015007': AcademicRole.coordination,
};

AcademicRole? roleForRegistration(String registration) =>
    demoAccounts[registration.trim().toUpperCase()];
