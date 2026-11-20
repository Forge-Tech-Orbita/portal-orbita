import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/constants/app_routes.dart';
import 'package:portal_orbita/features/admin/data/admin.dart';
import 'package:portal_orbita/features/admin/presentation/admin_login_screen.dart';
import 'package:portal_orbita/features/admin/presentation/admin_mfa_screen.dart';
import 'package:portal_orbita/features/admin/presentation/admin_shell.dart';
import 'package:portal_orbita/features/auth/presentation/login_screen.dart';

import 'helpers.dart';

Future<void> openAdminRoute(WidgetTester tester, String route) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(const MainApp());
  Navigator.of(tester.element(find.byType(LoginScreen))).pushNamed(route);
  await tester.pumpAndSettle();
}

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> dismissSnackBar(WidgetTester tester) async {
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
      .removeCurrentSnackBar();
  await tester.pumpAndSettle();
}

Future<void> wait900(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
}

void main() {
  group('validações administrativas', () {
    test('só contas adm.nome@orbita.edu entram', () {
      expect(validateAdminEmail('adm.ana@orbita.edu'), isNull);
      expect(validateAdminEmail('ADM.Lucas@orbita.edu'), isNull);
      expect(
        validateAdminEmail('marina.costa@orbita.edu'),
        'Use uma conta administrativa (adm.nome@orbita.edu).',
      );
      expect(validateAdminEmail(''), 'Informe o e-mail administrativo.');
    });

    test('código MFA tem 6 dígitos', () {
      expect(validateMfaCode('482913'), isNull);
      expect(validateMfaCode('4829'), isNotNull);
      expect(validateMfaCode('48291a'), isNotNull);
    });

    test('vigência deve ser data futura válida', () {
      final today = DateTime(2026, 11, 19);
      expect(validateValidity('31/12/2026', today), isNull);
      expect(
        validateValidity('19/11/2026', today),
        'A vigência deve terminar no futuro.',
      );
      expect(validateValidity('31/02/2027', today), 'Data inválida.');
      expect(
        validateValidity('2026-12-31', today),
        'Use o formato dd/mm/aaaa.',
      );
    });
  });

  testWidgets('login admin recusa conta acadêmica e segue para o MFA', (
    tester,
  ) async {
    await openAdminRoute(tester, AppRoutes.adminLogin);
    expect(find.byType(AdminLoginScreen), findsOneWidget);
    expect(find.text('PORTAL ADMINISTRATIVO'), findsOneWidget);
    expect(find.text('Conta administrativa separada'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'marina.costa@orbita.edu',
    );
    await tapVisible(tester, find.text('Continuar'));
    expect(
      find.text('Use uma conta administrativa (adm.nome@orbita.edu).'),
      findsOneWidget,
    );
    expect(find.text('Senha obrigatória'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'adm.ana@orbita.edu',
    );
    await tester.enterText(find.byType(TextFormField).last, 'segredo-demo');
    await tapVisible(tester, find.text('Continuar'));
    await wait900(tester);
    expect(find.byType(AdminMfaScreen), findsOneWidget);
  });

  testWidgets('MFA exige 6 dígitos e entra no painel limpando a pilha', (
    tester,
  ) async {
    await openAdminRoute(tester, AppRoutes.adminMfa);
    expect(find.text('Verificação obrigatória'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('mfa-code')), '4829');
    await tapVisible(tester, find.text('Verificar e entrar'));
    expect(find.text('Digite os 6 dígitos do autenticador.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('mfa-code')), '482913');
    await tapVisible(tester, find.text('Verificar e entrar'));
    await wait900(tester);
    expect(find.byType(AdminShell), findsOneWidget);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('MFA bloqueia após cinco tentativas inválidas', (tester) async {
    await openAdminRoute(tester, AppRoutes.adminMfa);
    for (var attempt = 0; attempt < maxMfaAttempts; attempt++) {
      await tapVisible(tester, find.text('Verificar e entrar'));
    }
    expect(find.textContaining('Conta bloqueada após 5 tentativas'), findsOne);
  });

  testWidgets('chave de segurança informa dependência de integração', (
    tester,
  ) async {
    await openAdminRoute(tester, AppRoutes.adminMfa);
    await tapVisible(tester, find.text('Usar chave de segurança'));
    expect(find.textContaining('provedor de identidade'), findsOneWidget);
  });
}
