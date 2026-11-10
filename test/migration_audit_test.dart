import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
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

Future<void> loginToPortal(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  expect(find.byType(LoginScreen), findsOneWidget);
  expect(find.textContaining('em migração'), findsNothing);
  await tester.ensureVisible(find.text('ENTRAR NO PORTAL'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'fluxo representativo percorre as 11 telas, preserva estado das abas e encerra sessão',
    (tester) async {
      await loginToPortal(tester);

      // 1. Home
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.textContaining('em migração'), findsNothing);

      // 2. Horário: seleciona SÁB e confere estado vazio
      await tester.tap(find.text('Horário'));
      await tester.pumpAndSettle();
      expect(find.byType(ScheduleScreen), findsOneWidget);
      expect(find.textContaining('em migração'), findsNothing);
      final satChip = find.widgetWithText(ChoiceChip, 'SÁB');
      await tester.ensureVisible(satChip);
      await tester.pumpAndSettle();
      await tester.tap(satChip);
      await tester.pumpAndSettle();
      expect(find.text('Sem aulas em Sábado'), findsOneWidget);

      // 3. Notas: filtra Cursando e expande Cálculo Numérico
      await tester.tap(find.text('Notas'));
      await tester.pumpAndSettle();
      expect(find.byType(GradesScreen), findsOneWidget);
      expect(find.textContaining('em migração'), findsNothing);
      final inProgressFilter = find.widgetWithText(ChoiceChip, 'Cursando');
      await tester.ensureVisible(inProgressFilter);
      await tester.pumpAndSettle();
      await tester.tap(inProgressFilter);
      await tester.pumpAndSettle();
      final gradeCard = find.widgetWithText(Card, 'Cálculo Numérico');
      await tester.ensureVisible(gradeCard);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: gradeCard, matching: find.text('Cálculo Numérico')),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Frequência: 82% · Situação: Em andamento'),
        findsOneWidget,
      );

      // 4. Cursos (Minhas disciplinas)
      await tester.tap(find.text('Cursos'));
      await tester.pumpAndSettle();
      expect(find.byType(CoursesScreen), findsOneWidget);
      expect(find.text('Minhas disciplinas'), findsOneWidget);
      expect(find.textContaining('em migração'), findsNothing);

      // 5. Mais e rotas secundárias: Financeiro, Biblioteca, Mural, Suporte
      await tester.tap(find.text('Mais'));
      await tester.pumpAndSettle();
      expect(find.byType(MoreScreen), findsOneWidget);
      expect(find.textContaining('em migração'), findsNothing);

      for (final (label, screenType, expectedText) in [
        ('Financeiro', FinancialScreen, 'MENSALIDADE · SETEMBRO'),
        ('Biblioteca', LibraryScreen, 'Estruturas de Dados e Algoritmos'),
        ('Mural', NoticesScreen, 'Matrícula do próximo período'),
        ('Suporte', SupportScreen, 'FALE COM A SECRETARIA'),
      ]) {
        final option = find.widgetWithText(OutlinedButton, label);
        await tester.ensureVisible(option);
        await tester.pumpAndSettle();
        await tester.tap(option);
        await tester.pumpAndSettle();

        expect(find.byType(screenType), findsOneWidget);
        expect(find.text(expectedText), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsNothing);
        expect(find.textContaining('em migração'), findsNothing);

        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(MoreScreen), findsOneWidget);
      }

      // 6. Confirma preservação do estado das abas após abrir/fechar secundárias
      await tester.tap(find.text('Horário'));
      await tester.pumpAndSettle();
      expect(find.text('Sem aulas em Sábado'), findsOneWidget);

      await tester.tap(find.text('Notas'));
      await tester.pumpAndSettle();
      expect(
        find.text('Frequência: 82% · Situação: Em andamento'),
        findsOneWidget,
      );

      // 7. Volta para Mais → Perfil → altera switch local → Encerrar sessão
      await tester.tap(find.text('Mais'));
      await tester.pumpAndSettle();
      final profileOption = find.widgetWithText(OutlinedButton, 'Perfil');
      await tester.ensureVisible(profileOption);
      await tester.pumpAndSettle();
      await tester.tap(profileOption);
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.textContaining('em migração'), findsNothing);
      final biometricsSwitch = find.widgetWithText(
        SwitchListTile,
        'Biometria facial',
      );
      await tester.ensureVisible(biometricsSwitch);
      await tester.pumpAndSettle();
      await tester.tap(biometricsSwitch);
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(biometricsSwitch).value, isTrue);

      final logoutButton = find.text('Encerrar sessão');
      await tester.ensureVisible(logoutButton);
      await tester.pumpAndSettle();
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        find.byType(MainNavigationScreen, skipOffstage: false),
        findsNothing,
      );
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      expect(await navigator.maybePop(), isFalse);
    },
  );

  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(360, 640),
  ]) {
    testWidgets(
      'login com teclado e navegação pelas telas secundárias sem overflow em $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetViewInsets);

        await tester.pumpWidget(const MainApp());
        await tester.ensureVisible(find.text('ENTRAR NO PORTAL'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        await tester.tap(find.text('ENTRAR NO PORTAL'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 900));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Mais'));
        await tester.pumpAndSettle();

        for (final (label, lastTargetText) in [
          ('Financeiro', 'Maio/2026'),
          ('Biblioteca', '18 dias'),
          ('Mural', '4 dias atrás'),
          ('Suporte', 'Acesse Notas → detalhes da disciplina.'),
          ('Perfil', 'Encerrar sessão'),
        ]) {
          final option = find.widgetWithText(OutlinedButton, label);
          await tester.ensureVisible(option);
          await tester.pumpAndSettle();
          await tester.tap(option);
          await tester.pumpAndSettle();

          final target = find.text(lastTargetText);
          await tester.ensureVisible(target);
          await tester.pumpAndSettle();
          expect(target.hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      },
    );
  }
}
