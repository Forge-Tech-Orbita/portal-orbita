import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/constants/app_routes.dart';
import 'package:portal_orbita/core/theme/orbita_theme.dart';
import 'package:portal_orbita/features/auth/presentation/login_screen.dart';
import 'package:portal_orbita/features/courses/presentation/courses_screen.dart';
import 'package:portal_orbita/features/financial/presentation/financial_screen.dart';
import 'package:portal_orbita/features/grades/presentation/grades_screen.dart';
import 'package:portal_orbita/features/home/presentation/home_screen.dart';
import 'package:portal_orbita/features/library/presentation/library_screen.dart';
import 'package:portal_orbita/features/more/presentation/more_screen.dart';
import 'package:portal_orbita/features/navigation/presentation/main_navigation_screen.dart';
import 'package:portal_orbita/features/notices/presentation/notices_screen.dart';
import 'package:portal_orbita/features/profile/presentation/profile_screen.dart';
import 'package:portal_orbita/features/schedule/presentation/schedule_screen.dart';
import 'package:portal_orbita/features/support/presentation/support_screen.dart';

Future<void> enterPortal(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
}

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
    expect(theme.colorScheme.surface, OrbitaTheme.surface);
    expect(theme.colorScheme.onSurface, OrbitaTheme.text);
  });

  testWidgets('entrar limpa Login e abas alternam sem empilhar ou recriar', (
    tester,
  ) async {
    await enterPortal(tester);

    expect(find.byType(LoginScreen), findsNothing);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    final home = tester.element(find.byType(HomeScreen));
    expect(navigator.canPop(), isFalse);

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
        index,
      );
      expect(navigator.canPop(), isFalse);
      expect(
        tester.element(find.byType(HomeScreen, skipOffstage: false)),
        same(home),
      );
      index++;
    }
  });

  for (final (label, screenType, route) in [
    ('Financeiro', FinancialScreen, AppRoutes.financial),
    ('Biblioteca', LibraryScreen, AppRoutes.library),
    ('Mural', NoticesScreen, AppRoutes.notices),
    ('Perfil', ProfileScreen, AppRoutes.profile),
    ('Suporte', SupportScreen, AppRoutes.support),
  ]) {
    testWidgets('$label abre sem barra inferior e retorna à aba Mais', (
      tester,
    ) async {
      await enterPortal(tester);
      await tester.tap(find.text('Mais'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(find.byType(screenType), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.byType(BackButton), findsOneWidget);
      expect(
        ModalRoute.of(tester.element(find.byType(screenType)))!.settings.name,
        route,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(MoreScreen), findsOneWidget);
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        4,
      );
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
        isFalse,
      );
    });
  }

  testWidgets('Sair limpa a sessão e novo login reinicia na aba Início', (
    tester,
  ) async {
    await enterPortal(tester);
    await tester.tap(find.text('Mais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
      find.byType(MainNavigationScreen, skipOffstage: false),
      findsNothing,
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(await navigator.maybePop(), isFalse);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.tap(find.text('ENTRAR NO PORTAL'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(navigator.canPop(), isFalse);
  });

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
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(
      ModalRoute.of(tester.element(find.text('Rota não encontrada')))!
          .settings
          .name,
      '/inexistente',
    );
  });

  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(360, 640),
  ]) {
    testWidgets('estrutura navegável sem overflow em $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await enterPortal(tester);
      await tester.tap(find.text('Mais'));
      await tester.pumpAndSettle();
      expect(find.text('Sair').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
