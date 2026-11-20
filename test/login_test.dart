import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/constants/app_routes.dart';
import 'package:portal_orbita/core/mock/demo_accounts.dart';
import 'package:portal_orbita/features/auth/presentation/login_screen.dart';
import 'package:portal_orbita/features/auth/presentation/widgets/biometric_sheet.dart';
import 'package:portal_orbita/features/navigation/presentation/main_navigation_screen.dart';

import 'helpers.dart';

Future<void> submit(WidgetTester tester) async {
  await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
}

void main() {
  test('contas de demonstração resolvem o perfil sem diferenciar caixa', () {
    expect(roleForRegistration('2023104567'), AcademicRole.student);
    expect(roleForRegistration(' p2019042 '), AcademicRole.professor);
    expect(roleForRegistration('C2015007'), AcademicRole.coordination);
    expect(roleForRegistration('0000'), isNull);
    expect(AcademicRole.student.homeRoute, AppRoutes.main);
  });

  testWidgets('exibe identidade, campos rotulados e senha oculta', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('ÓRBITA'), findsOneWidget);
    expect(find.text('ENSINO EM OUTRA ÓRBITA'), findsOneWidget);
    expect(find.text('Matrícula'), findsOneWidget);
    expect(find.text('Senha de acesso'), findsOneWidget);
    expect(find.text('2023104567'), findsOneWidget);
    final password = tester.widget<EditableText>(
      find.descendant(
        of: find.byType(TextFormField).last,
        matching: find.byType(EditableText),
      ),
    );
    expect(password.obscureText, isTrue);
    expect(find.text('Acessar com biometria'), findsOneWidget);
    expect(
      find.textContaining('aluno, professor e coordenação'),
      findsOneWidget,
    );
  });

  testWidgets('valida campos obrigatórios', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.enterText(find.byType(TextFormField).last, '');
    await submit(tester);

    expect(find.text('Matrícula obrigatória'), findsOneWidget);
    expect(find.text('Senha obrigatória'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('loading bloqueia duplicidade e só entra após 900 ms', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.tap(find.text('ENTRAR NO PORTAL'));
    await tester.pump();
    expect(find.text('AUTENTICANDO...'), findsOneWidget);
    await tester.tap(find.text('AUTENTICANDO...'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 899));
    expect(find.byType(MainNavigationScreen), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationScreen), findsOneWidget);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('matrícula desconhecida mostra erro e conta tentativas', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.enterText(find.byType(TextFormField).first, '1111');

    await submit(tester);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    expect(find.text('Matrícula ou senha incorretos'), findsOneWidget);
    expect(
      find.text('Restam 4 tentativas antes do bloqueio temporário.'),
      findsOneWidget,
    );
    expect(find.text('Acessar com biometria'), findsNothing);

    for (var attempt = 2; attempt <= maxLoginAttempts; attempt++) {
      await submit(tester);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();
    }
    expect(find.text('Acesso bloqueado temporariamente'), findsOneWidget);
    final button = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('ENTRAR NO PORTAL'),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('biometria simulada entra como aluna e pode ser cancelada', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tapVisible(tester, find.text('Acessar com biometria'));
    expect(find.byType(BiometricSheet), findsOneWidget);
    expect(find.textContaining('Marina Duarte'), findsOneWidget);

    await tapVisible(tester, find.text('Usar matrícula e senha'));
    expect(find.byType(BiometricSheet), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);

    await tapVisible(tester, find.text('Acessar com biometria'));
    await tapVisible(tester, find.text('Simular leitura aprovada'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });

  testWidgets('biometria fica oculta quando indisponível (Web)', (
    tester,
  ) async {
    await pumpScreen(tester, const LoginScreen(biometricsAvailable: false));
    expect(find.text('Acessar com biometria'), findsNothing);
  });

  testWidgets('esqueci minha senha orienta procurar a secretaria', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tapVisible(tester, find.text('Esqueci minha senha'));
    expect(find.textContaining('secretaria acadêmica'), findsOneWidget);
  });

  for (final size in testViewports) {
    testWidgets('formulário com teclado não gera overflow em $size', (
      tester,
    ) async {
      useViewport(tester, size);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(const MainApp());
      await tester.ensureVisible(find.text('ENTRAR NO PORTAL'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
