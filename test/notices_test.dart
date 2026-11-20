import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/mock/notices_mock.dart';
import 'package:portal_orbita/core/models/notice.dart';
import 'package:portal_orbita/core/widgets/notice_tile.dart';
import 'package:portal_orbita/features/notices/presentation/notices_screen.dart';

import 'helpers.dart';

void main() {
  test('avisos têm IDs únicos, um evento e o mural recente do Início', () {
    expect(demoNotices.map((n) => n.id).toSet(), hasLength(4));
    expect(demoNotices.where((n) => n.isEvent).map((n) => n.id), [
      'technology-week',
    ]);
    expect(recentNotices.map((n) => n.shortTitle ?? n.title), [
      'Matrícula 2027.1',
      'Semana de Tecnologia Órbita',
    ]);
    expect(demoNotices.map((n) => n.category), [
      NoticeCategory.events,
      NoticeCategory.academic,
      NoticeCategory.financial,
      NoticeCategory.academic,
    ]);
  });

  testWidgets('mural destaca o evento e lista os demais avisos', (
    tester,
  ) async {
    await pumpScreen(tester, const NoticesScreen());

    expect(find.text('Semana de Tecnologia Órbita'), findsOneWidget);
    expect(find.text('24/11/2026 · 19:00 · Auditório · Bloco C'), findsOne);
    expect(find.text('Coordenação · ontem · 17:40'), findsOneWidget);
    expect(
      tester
          .widgetList<NoticeTile>(find.byType(NoticeTile))
          .map((tile) => tile.notice.id),
      ['enrollment', 'november-invoice', 'lab-maintenance'],
    );
  });

  testWidgets('confirmar presença alterna o estado do evento', (tester) async {
    await pumpScreen(tester, const NoticesScreen());

    await tapVisible(tester, find.text('Confirmar presença'));
    expect(find.text('Presença confirmada'), findsOneWidget);
    expect(
      find.text('Presença confirmada em Semana de Tecnologia Órbita.'),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('Presença confirmada'));
    expect(find.text('Confirmar presença'), findsOneWidget);
  });

  for (final size in testViewports) {
    testWidgets('último aviso alcançável sem overflow em $size', (
      tester,
    ) async {
      useViewport(tester, size, textScale: 2);
      await pumpScreen(tester, const NoticesScreen());
      await tester.ensureVisible(find.text('16/11/2026'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
