import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/mock/notifications_mock.dart';
import 'package:portal_orbita/core/widgets/info_card.dart';
import 'package:portal_orbita/features/notifications/presentation/notifications_screen.dart';

import 'helpers.dart';

void main() {
  test('fixtures têm cinco notificações e três não lidas', () {
    expect(demoNotifications, hasLength(5));
    expect(demoNotifications.where((item) => !item.read), hasLength(3));
  });

  testWidgets('filtra não lidas, marca uma e depois todas', (tester) async {
    await pumpScreen(tester, const NotificationsScreen());

    expect(find.byType(InfoCard), findsNWidgets(5));
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Não lidas (3)'));
    expect(find.byType(InfoCard), findsNWidgets(3));

    await tapVisible(tester, find.text('Fatura de novembro disponível'));
    expect(find.widgetWithText(ChoiceChip, 'Não lidas (2)'), findsOneWidget);
    expect(find.byType(InfoCard), findsNWidgets(2));

    await tapVisible(tester, find.text('Marcar todas como lidas'));
    expect(find.text('Nenhuma notificação não lida.'), findsOneWidget);
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Todas'));
    expect(find.byType(InfoCard), findsNWidgets(5));
  });

  testWidgets('lista compartilhada recebe as alterações', (tester) async {
    final shared = ValueNotifier(demoNotifications);
    addTearDown(shared.dispose);
    await pumpScreen(tester, NotificationsScreen(notifications: shared));
    await tapVisible(tester, find.text('Marcar todas como lidas'));
    expect(shared.value.every((item) => item.read), isTrue);
  });

  for (final size in testViewports) {
    testWidgets('notificações sem overflow em $size', (tester) async {
      useViewport(tester, size, textScale: 2);
      await pumpScreen(tester, const NotificationsScreen());
      await tester.ensureVisible(find.text('Marcar todas como lidas'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
