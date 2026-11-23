import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/constants/app_routes.dart';
import 'package:portal_orbita/features/auth/presentation/login_screen.dart';
import 'package:portal_orbita/features/financial/presentation/payment_screen.dart';
import 'package:portal_orbita/features/grades/presentation/grades_screen.dart';
import 'package:portal_orbita/features/library/presentation/catalog_screen.dart';
import 'package:portal_orbita/features/navigation/presentation/main_navigation_screen.dart';
import 'package:portal_orbita/features/notifications/presentation/notifications_screen.dart';
import 'package:portal_orbita/features/schedule/presentation/schedule_screen.dart';

import 'helpers.dart';

/// Rotas secundárias do aluno e um texto do fim de cada tela.
const _secondaryRoutes = [
  (AppRoutes.financial, 'Agosto/2026'),
  (AppRoutes.payment, 'Baixar PDF da 2ª via'),
  (AppRoutes.library, '18 dias'),
  (AppRoutes.catalog, 'Revista de Computação Aplicada'),
  (AppRoutes.materials, 'Manual do Aluno 2026'),
  (AppRoutes.notices, '16/11/2026'),
  (AppRoutes.notifications, 'Marcar todas como lidas'),
  (AppRoutes.support, 'Acesse Notas → toque na disciplina.'),
  (AppRoutes.newTicket, 'Cancelar'),
  (AppRoutes.profile, 'Encerrar sessão'),
  (AppRoutes.professorNewMaterial, 'Publicar material'),
  (AppRoutes.coordinationNewMaterial, 'Publicar material'),
];

void main() {
  testWidgets(
    'fluxo do aluno percorre abas e rotas novas, preserva estado e sai',
    (tester) async {
      await loginAs(tester);

      await tester.tap(find.text('Horário'));
      await tester.pumpAndSettle();
      expect(find.byType(ScheduleScreen), findsOneWidget);
      await tapVisible(tester, find.widgetWithText(ChoiceChip, 'SÁB'));
      expect(find.text('Sem aulas em Sábado'), findsOneWidget);

      await tester.tap(find.text('Notas'));
      await tester.pumpAndSettle();
      expect(find.byType(GradesScreen), findsOneWidget);
      await tapVisible(tester, find.text('Banco de Dados II'));

      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Notificações, 3 não lidas'));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await openFromMore(tester, 'Financeiro');
      await tapVisible(tester, find.text('Pagar com Pix'));
      expect(find.byType(PaymentScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tapVisible(tester, find.text('Biblioteca'));
      await tapVisible(tester, find.text('ver acervo'));
      expect(find.byType(CatalogScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Horário'));
      await tester.pumpAndSettle();
      expect(find.text('Sem aulas em Sábado'), findsOneWidget);
      await tester.tap(find.text('Notas'));
      await tester.pumpAndSettle();
      expect(find.text('Frequência: 86% · Situação: Cursando'), findsOneWidget);

      await openFromMore(tester, 'Sair');
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        find.byType(MainNavigationScreen, skipOffstage: false),
        findsNothing,
      );
    },
  );

  for (final size in testViewports) {
    testWidgets('rotas secundárias sem overflow com texto 1,5× em $size', (
      tester,
    ) async {
      useViewport(tester, size, textScale: 1.5);
      await loginAs(tester);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));

      for (final (route, lastText) in _secondaryRoutes) {
        navigator.pushNamed(route);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(lastText).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: route);
        navigator.pop();
        await tester.pumpAndSettle();
      }
    });
  }
}
