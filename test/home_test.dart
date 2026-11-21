import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/mock/notices_mock.dart';
import 'package:portal_orbita/core/widgets/metric_tile.dart';
import 'package:portal_orbita/core/widgets/notice_tile.dart';
import 'package:portal_orbita/core/widgets/page_heading.dart';
import 'package:portal_orbita/core/widgets/student_id_card.dart';
import 'package:portal_orbita/features/financial/presentation/financial_screen.dart';
import 'package:portal_orbita/features/home/presentation/home_screen.dart';
import 'package:portal_orbita/features/home/presentation/widgets/next_class_card.dart';
import 'package:portal_orbita/features/home/presentation/widgets/quick_action_tile.dart';
import 'package:portal_orbita/features/library/presentation/library_screen.dart';
import 'package:portal_orbita/features/notices/presentation/notices_screen.dart';
import 'package:portal_orbita/features/notifications/presentation/notifications_screen.dart';
import 'package:portal_orbita/features/support/presentation/support_screen.dart';

import 'helpers.dart';

void main() {
  test('saudação respeita limites de manhã, tarde e noite', () {
    for (final (hour, expected) in [
      (0, 'Bom dia'),
      (11, 'Bom dia'),
      (12, 'Boa tarde'),
      (17, 'Boa tarde'),
      (18, 'Boa noite'),
      (23, 'Boa noite'),
    ]) {
      expect(greetingForHour(hour), expected);
    }
  });

  testWidgets('início mostra carteirinha, métricas, atalhos e mural recente', (
    tester,
  ) async {
    await loginAs(tester);

    expect(find.text('Aluno Demonstração'), findsWidgets);
    expect(
      tester
          .widget<StudentIdCard>(find.byType(StudentIdCard))
          .student
          .registration,
      '202600001',
    );
    for (final (value, label) in [
      ('8.7', 'CRA geral'),
      ('91%', 'Frequência'),
      ('142', 'Créditos'),
    ]) {
      expect(find.widgetWithText(MetricTile, value), findsOneWidget);
      expect(find.widgetWithText(MetricTile, label), findsOneWidget);
    }
    expect(find.byType(NextClassCard), findsOneWidget);
    expect(find.text('Próxima aula · calculada pela grade'), findsOneWidget);
    expect(find.byType(QuickActionTile), findsNWidgets(4));

    await tester.ensureVisible(find.byType(NoticeTile).last);
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<NoticeTile>(find.byType(NoticeTile))
          .map((tile) => tile.notice),
      recentNotices,
    );
    expect(find.text('Matrícula 2027.1'), findsOneWidget);
    expect(find.text('Semana de Tecnologia Órbita'), findsOneWidget);
  });

  testWidgets('sino mostra não lidas e sincroniza ao marcar como lidas', (
    tester,
  ) async {
    await loginAs(tester);
    expect(find.byTooltip('Notificações, 3 não lidas'), findsOneWidget);

    await tester.tap(find.byTooltip('Notificações, 3 não lidas'));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationsScreen), findsOneWidget);
    await tapVisible(tester, find.text('Marcar todas como lidas'));
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byTooltip('Notificações'), findsOneWidget);
  });

  for (final (label, screen) in [
    ('Financeiro', FinancialScreen),
    ('Biblioteca', LibraryScreen),
    ('Avisos', NoticesScreen),
    ('Suporte', SupportScreen),
  ]) {
    testWidgets('atalho $label abre a tela sem barra inferior', (tester) async {
      await loginAs(tester);
      await tapVisible(tester, find.widgetWithText(QuickActionTile, label));

      expect(find.byType(screen), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  }

  testWidgets('ver tudo abre o mural completo', (tester) async {
    await loginAs(tester);
    await tapVisible(tester, find.text('ver tudo'));
    expect(find.byType(NoticesScreen), findsOneWidget);
  });

  for (final size in testViewports) {
    testWidgets('início rola até o último aviso sem overflow em $size', (
      tester,
    ) async {
      useViewport(tester, size);
      await loginAs(tester);
      await tester.ensureVisible(find.byType(NoticeTile).last);
      await tester.pumpAndSettle();
      expect(find.text('Palestras e feira no Bloco C').hitTestable(), findsOne);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('texto ampliado 2× mantém o início rolável', (tester) async {
    useViewport(tester, const Size(390, 844), textScale: 2);
    await loginAs(tester);
    await tester.ensureVisible(find.byType(NoticeTile).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
