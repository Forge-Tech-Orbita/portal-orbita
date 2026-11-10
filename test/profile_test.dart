import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/constants/app_routes.dart';
import 'package:portal_orbita/core/mock/student_mock.dart';
import 'package:portal_orbita/core/theme/orbita_theme.dart';
import 'package:portal_orbita/core/widgets/student_id_card.dart';
import 'package:portal_orbita/features/auth/presentation/login_screen.dart';
import 'package:portal_orbita/features/more/presentation/more_screen.dart';
import 'package:portal_orbita/features/navigation/presentation/main_navigation_screen.dart';
import 'package:portal_orbita/features/profile/presentation/profile_screen.dart';
import 'package:portal_orbita/features/support/presentation/support_screen.dart';

Future<void> openProfile(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  await tester.ensureVisible(find.text('ENTRAR NO PORTAL'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Mais'));
  await tester.pumpAndSettle();
  final profileOption = find.widgetWithText(OutlinedButton, 'Perfil');
  await tester.ensureVisible(profileOption);
  await tester.pumpAndSettle();
  await tester.tap(profileOption);
  await tester.pumpAndSettle();
}

Finder switchForLabel(String label) =>
    find.widgetWithText(SwitchListTile, label);

void main() {
  testWidgets(
    'perfil exibe carteirinha compacta compartilhada e dados mascarados',
    (tester) async {
      await openProfile(tester);
      expect(find.text('Meu perfil'), findsOneWidget);
      expect(find.text('CONTA'), findsOneWidget);
      final card = tester.widget<StudentIdCard>(find.byType(StudentIdCard));
      expect(card.student, same(demoStudent));
      expect(card.compact, isTrue);
      expect(find.text(demoStudent.name), findsOneWidget);
      expect(find.text(demoStudent.course), findsOneWidget);
      expect(find.text(demoStudent.registration), findsNothing);
      expect(find.text(demoStudent.validUntil), findsNothing);

      for (final (label, value) in [
        ('CPF', demoStudent.maskedCpf),
        ('E-mail institucional', demoStudent.email),
        ('Telefone', demoStudent.maskedPhone),
      ]) {
        await tester.ensureVisible(find.text(value));
        await tester.pumpAndSettle();
        expect(find.text(label), findsOneWidget);
        expect(find.text(value), findsOneWidget);
      }
      expect(
        find.text(
          'Preferências demonstrativas · efeito apenas visual nesta tela',
        ),
        findsOneWidget,
      );
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.textContaining('em migração'), findsNothing);
    },
  );

  testWidgets(
    'switches alternam independentemente sem mudar tema e reiniciam ao reabrir',
    (tester) async {
      await openProfile(tester);
      for (final (label, initial) in [
        ('Notificações push', true),
        ('Modo escuro', true),
        ('Biometria facial', false),
      ]) {
        final tile = switchForLabel(label);
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        expect(tester.widget<SwitchListTile>(tile).value, initial);
      }

      for (final (label, expectedAfterTap) in [
        ('Notificações push', false),
        ('Modo escuro', false),
        ('Biometria facial', true),
      ]) {
        final tile = switchForLabel(label);
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(tester.widget<SwitchListTile>(tile).value, expectedAfterTap);
      }

      expect(
        tester
            .widget<SwitchListTile>(switchForLabel('Notificações push'))
            .value,
        isFalse,
      );
      expect(
        tester.widget<SwitchListTile>(switchForLabel('Modo escuro')).value,
        isFalse,
      );
      expect(
        tester.widget<SwitchListTile>(switchForLabel('Biometria facial')).value,
        isTrue,
      );

      final theme = Theme.of(tester.element(find.byType(ProfileScreen)));
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, OrbitaTheme.background);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MoreScreen), findsOneWidget);

      final profileOption = find.widgetWithText(OutlinedButton, 'Perfil');
      await tester.ensureVisible(profileOption);
      await tester.pumpAndSettle();
      await tester.tap(profileOption);
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<SwitchListTile>(switchForLabel('Notificações push'))
            .value,
        isTrue,
      );
      expect(
        tester.widget<SwitchListTile>(switchForLabel('Modo escuro')).value,
        isTrue,
      );
      expect(
        tester.widget<SwitchListTile>(switchForLabel('Biometria facial')).value,
        isFalse,
      );
    },
  );

  testWidgets(
    'Encerrar sessão limpa a pilha mesmo quando Perfil abre sobre outra rota',
    (tester) async {
      await openProfile(tester);
      final profileContext = tester.element(find.byType(ProfileScreen));
      Navigator.of(profileContext).pushReplacementNamed(AppRoutes.support);
      await tester.pumpAndSettle();
      expect(find.byType(SupportScreen), findsOneWidget);

      Navigator.of(tester.element(find.byType(SupportScreen)))
          .pushNamed(AppRoutes.profile);
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);

      final logout = find.text('Encerrar sessão');
      await tester.ensureVisible(logout);
      await tester.pumpAndSettle();
      await tester.tap(logout);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        find.byType(MainNavigationScreen, skipOffstage: false),
        findsNothing,
      );
      expect(find.byType(SupportScreen, skipOffstage: false), findsNothing);
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
      'carteirinha, dados, switches e logout alcançáveis sem overflow em $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await openProfile(tester);

        for (final target in [
          find.byType(StudentIdCard),
          find.text(demoStudent.email),
          switchForLabel('Biometria facial'),
          find.text('Encerrar sessão'),
        ]) {
          await tester.ensureVisible(target);
          await tester.pumpAndSettle();
          expect(target.hitTestable(), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'texto ampliado mantém dados cadastrais, preferências e logout acessíveis',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openProfile(tester);

      for (final target in [
        find.text(demoStudent.name),
        find.text(demoStudent.maskedCpf),
        find.text(demoStudent.email),
        find.text(demoStudent.maskedPhone),
        switchForLabel('Notificações push'),
        switchForLabel('Modo escuro'),
        switchForLabel('Biometria facial'),
        find.text('Encerrar sessão'),
      ]) {
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
