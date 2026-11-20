import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/constants/app_routes.dart';
import 'package:portal_orbita/features/admin/data/admin.dart';
import 'package:portal_orbita/features/admin/presentation/admin_login_screen.dart';
import 'package:portal_orbita/features/admin/presentation/admin_mfa_screen.dart';
import 'package:portal_orbita/features/admin/presentation/admin_permissions_screen.dart';
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

    test('status de chamado avança em sentido único', () {
      expect(TicketStatus.open.next, TicketStatus.inProgress);
      expect(TicketStatus.inProgress.next, TicketStatus.resolved);
      expect(TicketStatus.resolved.next, isNull);
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

  testWidgets('painel mostra indicadores e leva às abas certas', (
    tester,
  ) async {
    await openAdminRoute(tester, AppRoutes.admin);

    expect(find.text('ÓRBITA ADMIN · PORTAL SEPARADO'), findsOneWidget);
    for (final text in ['1.284', '6', '2', '99,8%']) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.text('5 chamados de suporte abertos'), findsOneWidget);

    await tapVisible(tester, find.text('5 chamados de suporte abertos'));
    expect(
      find.text('Suporte técnico e requerimentos sobre o portal'),
      findsOne,
    );

    await openTab(tester, 'Painel');
    await tapVisible(tester, find.textContaining('Token acadêmico'));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Críticos'))
          .selected,
      isTrue,
    );
  });

  testWidgets('usuários filtram, bloqueiam e recebem convite', (tester) async {
    await openAdminRoute(tester, AppRoutes.admin);
    await openTab(tester, 'Usuários');

    await tester.enterText(find.byType(TextField).first, 'nakamura');
    await tester.pumpAndSettle();
    expect(find.text('R. Nakamura'), findsOneWidget);
    expect(find.text('Marina Duarte Costa'), findsNothing);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('João P. Silva'));
    await tapVisible(tester, find.text('Desbloquear conta'));
    expect(find.text('Conta desbloqueada.'), findsOneWidget);
    expect(find.text('Bloqueado'), findsNothing);

    await tapVisible(tester, find.text('Convidar usuário'));
    await tapVisible(tester, find.text('Enviar convite'));
    expect(find.text('Use um e-mail @orbita.edu.'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      ),
      'novo.prof@orbita.edu',
    );
    await tapVisible(tester, find.text('Enviar convite'));
    expect(find.text('novo.prof@orbita.edu'), findsOneWidget);

    await tapVisible(
      tester,
      find.widgetWithText(ChoiceChip, 'Administrativos'),
    );
    expect(find.text('Lucas Moreira'), findsOneWidget);
  });

  testWidgets('chamado é assumido, resolvido e respondido', (tester) async {
    await openAdminRoute(tester, AppRoutes.admin);
    await openTab(tester, 'Chamados');

    expect(find.widgetWithText(ChoiceChip, 'Abertos (5)'), findsOneWidget);
    expect(find.text('vence em 2 h'), findsOneWidget);

    await tapVisible(tester, find.text('Responder'));
    await tapVisible(tester, find.text('Enviar'));
    expect(find.text('Escreva a resposta.'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      ),
      'Estamos verificando o gerador de boletos.',
    );
    await tapVisible(tester, find.text('Enviar'));
    expect(find.textContaining('Resposta enviada em #SUP-0231'), findsOne);

    await dismissSnackBar(tester);
    await tapVisible(tester, find.text('Assumir'));
    expect(find.widgetWithText(ChoiceChip, 'Abertos (4)'), findsOneWidget);
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Em andamento'));
    expect(find.text('#SUP-0231 · Erro ao gerar boleto'), findsOneWidget);

    await dismissSnackBar(tester);
    await tapVisible(tester, find.text('Marcar como resolvido'));
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Resolvidos'));
    expect(find.text('#SUP-0231 · Erro ao gerar boleto'), findsOneWidget);
  });

  testWidgets('categoria filtra os chamados abertos', (tester) async {
    await openAdminRoute(tester, AppRoutes.admin);
    await openTab(tester, 'Chamados');
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Requerimento'));
    expect(find.text('#REQ-0087 · Exportar frequência em planilha'), findsOne);
    expect(find.text('#SUP-0231 · Erro ao gerar boleto'), findsNothing);
  });

  testWidgets('pedido de papel valida, impede a própria conta e registra', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: AdminPermissionsScreen(
          requests: const [],
          onRequest: (_) {},
          today: DateTime(2026, 11, 19),
        ),
      ),
    );
    await tapVisible(tester, find.text('Enviar para aprovação'));
    expect(find.text('Informe o e-mail administrativo.'), findsOneWidget);
    expect(find.text('Use o formato dd/mm/aaaa.'), findsOneWidget);

    await openAdminRoute(tester, AppRoutes.admin);
    await openTab(tester, 'Permissões');
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'adm.ana@orbita.edu');
    await tester.enterText(fields.at(1), '31/12/2099');
    await tester.enterText(fields.at(2), 'Suporte às integrações de 2027.');
    await tapVisible(tester, find.text('Enviar para aprovação'));
    expect(
      find.text('Você não pode pedir papel para a própria conta.'),
      findsOneWidget,
    );

    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .removeCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(0), 'adm.lucas@orbita.edu');
    await tapVisible(tester, find.text('Enviar para aprovação'));
    expect(
      find.text('Pedido enviado para aprovação de outro superadmin.'),
      findsOneWidget,
    );
    expect(find.text('Administrador de TI · adm.lucas@orbita.edu'), findsOne);

    await openTab(tester, 'Auditoria');
    expect(find.text('Pedido de papel: Administrador de TI'), findsOneWidget);
  });

  testWidgets('auditoria filtra hoje, sete dias e críticos', (tester) async {
    await openAdminRoute(tester, AppRoutes.admin);
    await openTab(tester, 'Auditoria');

    expect(find.text('Papel removido · Suporte N1'), findsNothing);
    await tapVisible(tester, find.widgetWithText(ChoiceChip, '7 dias'));
    expect(find.text('Papel removido · Suporte N1'), findsOneWidget);
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Críticos'));
    expect(find.text('Login admin com MFA'), findsNothing);
    expect(find.text('Negado 403'), findsOneWidget);
  });

  testWidgets('sair volta ao login administrativo sem histórico', (
    tester,
  ) async {
    await openAdminRoute(tester, AppRoutes.admin);
    await tester.tap(find.byTooltip('Sair do portal administrativo'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminLoginScreen), findsOneWidget);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });

  for (final size in testViewports) {
    testWidgets('portal admin sem overflow com texto 2× em $size', (
      tester,
    ) async {
      useViewport(tester, size, textScale: 2);
      await openAdminRoute(tester, AppRoutes.adminLogin);
      await tester.ensureVisible(find.text('Continuar'));
      await tester.pumpAndSettle();
      await openAdminRoute(tester, AppRoutes.adminMfa);
      await tester.ensureVisible(find.text('Usar chave de segurança'));
      await tester.pumpAndSettle();
      await openAdminRoute(tester, AppRoutes.admin);
      for (final (tab, lastText) in [
        ('Painel', '5 chamados de suporte abertos'),
        ('Usuários', 'Convidar usuário'),
        ('Chamados', 'Assumir'),
        ('Permissões', 'Enviar para aprovação'),
        ('Auditoria', 'Token acadêmico na API admin'),
      ]) {
        await openTab(tester, tab);
        await tester.ensureVisible(find.text(lastText).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: tab);
      }
    });
  }
}
