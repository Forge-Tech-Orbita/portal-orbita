import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/mock/notices_mock.dart';
import 'package:portal_orbita/core/widgets/notice_tile.dart';
import 'package:portal_orbita/features/home/presentation/home_screen.dart';
import 'package:portal_orbita/features/notices/presentation/notices_screen.dart';

Future<void> enterPortalForNotices(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  await tester.ensureVisible(find.text('ENTRAR NO PORTAL'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
}

Future<void> openNotices(WidgetTester tester) async {
  await enterPortalForNotices(tester);
  final bell = find.byTooltip('Abrir mural de avisos');
  await tester.ensureVisible(bell);
  await tester.pumpAndSettle();
  await tester.tap(bell);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mural mostra quatro avisos completos na ordem original', (
    tester,
  ) async {
    await openNotices(tester);
    expect(find.text('Mural de avisos'), findsOneWidget);
    expect(find.text('Comunicados e datas de demonstração'), findsOneWidget);
    final tiles = tester
        .widgetList<NoticeTile>(find.byType(NoticeTile))
        .toList();
    expect(tiles, hasLength(4));
    for (var index = 0; index < demoNotices.length; index++) {
      final notice = demoNotices[index];
      expect(tiles[index].notice, same(notice));
      expect(tiles[index].compact, isFalse);
      final tile = find.widgetWithText(NoticeTile, notice.title);
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      for (final text in [
        notice.category.label,
        notice.body,
        notice.dateText,
      ]) {
        expect(
          find.descendant(of: tile, matching: find.text(text)),
          findsOneWidget,
        );
      }
      if (notice.summary != null) {
        expect(find.text(notice.summary!), findsNothing);
      }
    }
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });

  testWidgets('resumos da Home e mural usam as mesmas instâncias e IDs', (
    tester,
  ) async {
    await enterPortalForNotices(tester);
    final previews = tester
        .widgetList<NoticeTile>(find.byType(NoticeTile))
        .map((tile) => tile.notice)
        .toList();
    expect(previews, hasLength(3));
    final viewAll = find.widgetWithText(TextButton, 'ver tudo');
    await tester.ensureVisible(viewAll);
    await tester.pumpAndSettle();
    await tester.tap(viewAll);
    await tester.pumpAndSettle();

    expect(find.byType(NoticesScreen), findsOneWidget);
    final fullNotices = tester
        .widgetList<NoticeTile>(find.byType(NoticeTile))
        .map((tile) => tile.notice)
        .toList();
    expect(fullNotices, hasLength(4));
    expect(
      fullNotices.take(3).map((notice) => notice.id),
      previews.map((notice) => notice.id),
    );
    for (var index = 0; index < previews.length; index++) {
      expect(fullNotices[index], same(previews[index]));
    }
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      tester
          .widgetList<NoticeTile>(find.byType(NoticeTile))
          .map((tile) => tile.notice.id),
      previews.map((notice) => notice.id),
    );
  });

  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(360, 640),
  ]) {
    testWidgets(
      'quatro avisos e última data alcançáveis sem overflow em $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await openNotices(tester);

        for (final notice in demoNotices) {
          final body = find.text(notice.body);
          await tester.ensureVisible(body);
          await tester.pumpAndSettle();
          expect(body.hitTestable(), findsOneWidget);
        }
        await tester.ensureVisible(find.text('4 dias atrás'));
        await tester.pumpAndSettle();
        expect(find.text('4 dias atrás').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'texto ampliado mantém comunicados completos legíveis por rolagem',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openNotices(tester);

      for (final notice in demoNotices) {
        for (final text in [notice.title, notice.body, notice.dateText]) {
          final target = find.text(text);
          await tester.ensureVisible(target);
          await tester.pumpAndSettle();
          expect(target.hitTestable(), findsOneWidget);
        }
      }
      expect(tester.takeException(), isNull);
    },
  );
}
