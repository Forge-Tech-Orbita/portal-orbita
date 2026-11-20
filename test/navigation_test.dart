import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/constants/app_routes.dart';
import 'package:portal_orbita/core/theme/orbita_theme.dart';
import 'package:portal_orbita/features/auth/presentation/login_screen.dart';
import 'package:portal_orbita/features/courses/presentation/courses_screen.dart';
import 'package:portal_orbita/features/grades/presentation/grades_screen.dart';
import 'package:portal_orbita/features/home/presentation/home_screen.dart';
import 'package:portal_orbita/features/more/presentation/more_screen.dart';
import 'package:portal_orbita/features/navigation/presentation/main_navigation_screen.dart';
import 'package:portal_orbita/features/schedule/presentation/schedule_screen.dart';

import 'helpers.dart';

void main() {
  testWidgets('inicia no Login sem barra inferior e com tema claro', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    final theme = Theme.of(tester.element(find.byType(LoginScreen)));
    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, OrbitaTheme.background);
    expect(theme.colorScheme.onSurface, OrbitaTheme.text);
  });

  testWidgets('abas do aluno alternam sem empilhar nem recriar', (
    tester,
  ) async {
    await loginAs(tester);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    final home = tester.element(find.byType(HomeScreen));

    var index = 0;
    for (final (label, screenType) in [
      ('Início', HomeScreen),
      ('Horário', ScheduleScreen),
      ('Notas', GradesScreen),
      ('Cursos', CoursesScreen),
      ('Mais', MoreScreen),
    ]) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.byType(screenType), findsOneWidget);
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        index++,
      );
      expect(navigator.canPop(), isFalse);
      expect(
        tester.element(find.byType(HomeScreen, skipOffstage: false)),
        same(home),
      );
    }
  });

  for (final (registration, shell, route) in [
    ('2023104567', MainNavigationScreen, AppRoutes.main),
  ]) {
    testWidgets('matrícula $registration abre a casca do perfil', (
      tester,
    ) async {
      await loginAs(tester, registration);
      expect(find.byType(shell), findsOneWidget);
      expect(currentRouteName(tester, shell), route);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      expect(navigator.canPop(), isFalse);
    });
  }

  testWidgets('rota desconhecida exibe fallback sem abrir sessão', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    final context = tester.element(find.byType(LoginScreen));
    Navigator.of(context).pushNamed('/inexistente');
    await tester.pumpAndSettle();

    expect(find.text('Rota não encontrada'), findsOneWidget);
    expect(
      find.byType(MainNavigationScreen, skipOffstage: false),
      findsNothing,
    );
    expect(
      ModalRoute.of(tester.element(find.text('Rota não encontrada')))!
          .settings
          .name,
      '/inexistente',
    );
  });

  testWidgets('chamado enviado sem chamado nos argumentos cai no fallback', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    Navigator.of(tester.element(find.byType(LoginScreen)))
        .pushNamed(AppRoutes.ticketSent);
    await tester.pumpAndSettle();
    expect(find.text('Rota não encontrada'), findsOneWidget);
  });
}
