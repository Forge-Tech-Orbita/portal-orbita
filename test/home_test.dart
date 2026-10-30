import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/constants/app_routes.dart';
import 'package:portal_orbita/core/mock/notices_mock.dart';
import 'package:portal_orbita/core/mock/student_mock.dart';
import 'package:portal_orbita/core/widgets/notice_tile.dart';
import 'package:portal_orbita/core/widgets/student_id_card.dart';
import 'package:portal_orbita/features/financial/presentation/financial_screen.dart';
import 'package:portal_orbita/features/home/presentation/home_screen.dart';
import 'package:portal_orbita/features/home/presentation/widgets/academic_stat_tile.dart';
import 'package:portal_orbita/features/home/presentation/widgets/next_class_card.dart';
import 'package:portal_orbita/features/home/presentation/widgets/quick_action_tile.dart';
import 'package:portal_orbita/features/library/presentation/library_screen.dart';
import 'package:portal_orbita/features/notices/presentation/notices_screen.dart';
import 'package:portal_orbita/features/support/presentation/support_screen.dart';

Future<void> openHome(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
}

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

  testWidgets(
    'Home exibe dados, componentes compartilhados e próxima aula fixa',
    (tester) async {
      await openHome(tester);

      expect(find.text(demoStudent.shortName), findsOneWidget);
      expect(
        find.textContaining(RegExp(r'^(Bom dia|Boa tarde|Boa noite)$')),
        findsOneWidget,
      );
      final studentCard = tester.widget<StudentIdCard>(
        find.byType(StudentIdCard),
      );
      expect(studentCard.student, same(demoStudent));
      expect(studentCard.compact, isFalse);
      expect(find.byType(AcademicStatTile), findsNWidgets(3));
      for (final (value, label) in [
        ('8.7', 'CRA geral'),
        ('94%', 'Frequência'),
        ('142', 'Créditos'),
      ]) {
        expect(find.widgetWithText(AcademicStatTile, value), findsOneWidget);
        expect(find.widgetWithText(AcademicStatTile, label), findsOneWidget);
      }

      await tester.ensureVisible(find.byType(NextClassCard));
      await tester.pumpAndSettle();
      expect(find.text('Próxima aula · demonstração'), findsOneWidget);
      expect(find.text('Inteligência Artificial'), findsOneWidget);
      expect(
        find.text('Sala 304 · Bloco C · Prof. R. Nakamura'),
        findsOneWidget,
      );
      expect(find.text('19:00'), findsOneWidget);
      expect(find.text('em 47 min'), findsOneWidget);
      await tester.pump(const Duration(minutes: 1));
      expect(find.text('em 47 min'), findsOneWidget);
      expect(find.byType(QuickActionTile), findsNWidgets(4));

      await tester.ensureVisible(find.byType(NoticeTile).last);
      await tester.pumpAndSettle();
      expect(find.text('Mural recente'), findsOneWidget);
      final notices = tester
          .widgetList<NoticeTile>(find.byType(NoticeTile))
          .toList();
      expect(notices, hasLength(3));
      for (var index = 0; index < notices.length; index++) {
        expect(notices[index].notice, same(demoNotices[index]));
        expect(notices[index].compact, isTrue);
        expect(find.text(demoNotices[index].summary!), findsOneWidget);
      }
      expect(find.text(demoNotices.last.body), findsNothing);
    },
  );

  for (final (label, screenType, route) in [
    ('Financeiro', FinancialScreen, AppRoutes.financial),
    ('Biblioteca', LibraryScreen, AppRoutes.library),
    ('Avisos', NoticesScreen, AppRoutes.notices),
    ('Suporte', SupportScreen, AppRoutes.support),
    ('Sino', NoticesScreen, AppRoutes.notices),
    ('ver tudo', NoticesScreen, AppRoutes.notices),
  ]) {
    testWidgets(
      '$label abre destino correto e retorna à Home preservando rolagem',
      (tester) async {
        await openHome(tester);
        final home = tester.element(find.byType(HomeScreen));
        final target = switch (label) {
          'Sino' => find.byTooltip('Abrir mural de avisos'),
          'ver tudo' => find.widgetWithText(TextButton, label),
          _ => find.widgetWithText(QuickActionTile, label),
        };
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        final scrollable = tester.state<ScrollableState>(
          find.descendant(
            of: find.byType(HomeScreen),
            matching: find.byType(Scrollable),
          ),
        );
        final offset = scrollable.position.pixels;
        await tester.tap(target);
        await tester.pumpAndSettle();

        expect(find.byType(screenType), findsOneWidget);
        expect(
          ModalRoute.of(tester.element(find.byType(screenType)))!.settings.name,
          route,
        );
        expect(find.byType(BottomNavigationBar), findsNothing);
        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(tester.element(find.byType(HomeScreen)), same(home));
        expect(scrollable.position.pixels, offset);
        expect(
          tester
              .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
              .currentIndex,
          0,
        );
        expect(
          tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
          isFalse,
        );
      },
    );
  }

  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(360, 640),
  ]) {
    testWidgets(
      'dashboard permite rolar até o último aviso sem overflow em $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await openHome(tester);

        for (final label in ['Financeiro', 'Biblioteca', 'Avisos', 'Suporte']) {
          final action = find.widgetWithText(QuickActionTile, label);
          await tester.ensureVisible(action);
          await tester.pumpAndSettle();
          expect(action.hitTestable(), findsOneWidget);
        }
        await tester.ensureVisible(find.byType(NoticeTile).last);
        await tester.pumpAndSettle();
        expect(
          find.text(demoNotices[2].summary!).hitTestable(),
          findsOneWidget,
        );
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
