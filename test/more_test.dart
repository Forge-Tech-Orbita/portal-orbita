import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/widgets/info_card.dart';
import 'package:portal_orbita/features/auth/presentation/login_screen.dart';
import 'package:portal_orbita/features/financial/presentation/financial_screen.dart';
import 'package:portal_orbita/features/library/presentation/library_screen.dart';
import 'package:portal_orbita/features/materials/presentation/materials_screen.dart';
import 'package:portal_orbita/features/more/presentation/more_screen.dart';
import 'package:portal_orbita/features/notices/presentation/notices_screen.dart';
import 'package:portal_orbita/features/profile/presentation/profile_screen.dart';
import 'package:portal_orbita/features/support/presentation/support_screen.dart';

import 'helpers.dart';

void main() {
  testWidgets('menu mostra as sete opções do protótipo na ordem', (
    tester,
  ) async {
    await pumpScreen(tester, const Scaffold(body: MoreScreen()));

    expect(find.text('ATALHOS'), findsOneWidget);
    expect(
      tester.widgetList<InfoCard>(find.byType(InfoCard)).map((c) => c.title),
      [
        'Financeiro',
        'Biblioteca',
        'Materiais das disciplinas',
        'Mural de avisos',
        'Suporte',
        'Meu perfil',
        'Sair',
      ],
    );
    expect(find.text('Encerrar sessão neste aparelho'), findsOneWidget);
  });

  for (final (label, screen) in [
    ('Financeiro', FinancialScreen),
    ('Biblioteca', LibraryScreen),
    ('Materiais das disciplinas', MaterialsScreen),
    ('Mural de avisos', NoticesScreen),
    ('Suporte', SupportScreen),
    ('Meu perfil', ProfileScreen),
  ]) {
    testWidgets('$label abre como rota secundária', (tester) async {
      await loginAs(tester);
      await openFromMore(tester, label);
      expect(find.byType(screen), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MoreScreen), findsOneWidget);
    });
  }

  testWidgets('Sair limpa a pilha e volta ao login', (tester) async {
    await loginAs(tester);
    await openFromMore(tester, 'Sair');
    expect(find.byType(LoginScreen), findsOneWidget);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(await navigator.maybePop(), isFalse);
  });

  for (final size in testViewports) {
    testWidgets('opções alcançáveis com texto ampliado em $size', (
      tester,
    ) async {
      useViewport(tester, size, textScale: 2);
      await pumpScreen(tester, const Scaffold(body: MoreScreen()));
      await tester.ensureVisible(find.text('Sair'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
