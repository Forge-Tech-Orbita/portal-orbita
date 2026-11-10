import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/features/courses/data/courses_mock.dart';
import 'package:portal_orbita/features/courses/presentation/courses_screen.dart';

Future<void> openCourses(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Cursos'));
  await tester.pumpAndSettle();
}

void main() {
  test('fixtures preservam as cinco disciplinas na ordem do legado', () {
    expect(
      demoCourses
          .map(
            (course) => (
              course.subject,
              course.professor,
              course.credits,
              course.progress,
              course.room,
            ),
          )
          .toList(),
      [
        ('Arquitetura de Software', 'Prof. F. Ramalho', 4, 78, 'Sala 210'),
        ('Inteligência Artificial', 'Prof. R. Nakamura', 4, 70, 'Sala 304'),
        ('Banco de Dados II', 'Prof.ª L. Andrade', 3, 65, 'Lab 05'),
        ('Engenharia de Requisitos', 'Prof.ª C. Bezerra', 4, 82, 'Sala 212'),
        ('Cálculo Numérico', 'Prof. E. Villas', 3, 55, 'Sala 108'),
      ],
    );
  });

  testWidgets(
    'semestre e cinco cards apresentam os dados e progressos corretos',
    (tester) async {
      await openCourses(tester);
      expect(find.text('SEMESTRE 2026.2'), findsOneWidget);
      expect(find.text('Minhas disciplinas'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(5));
      final architectureBar = find.descendant(
        of: find.widgetWithText(Card, 'Arquitetura de Software'),
        matching: find.byType(LinearProgressIndicator),
      );
      expect(
        tester.widget<LinearProgressIndicator>(architectureBar).value,
        0.78,
      );

      for (final course in demoCourses) {
        final card = find.widgetWithText(Card, course.subject);
        await tester.ensureVisible(card);
        await tester.pumpAndSettle();
        for (final text in [
          course.professor,
          '${course.credits} créditos',
          '${course.progress}% do semestre',
          course.room,
        ]) {
          expect(
            find.descendant(of: card, matching: find.text(text)),
            findsOneWidget,
          );
        }
        final bar = find.descendant(
          of: card,
          matching: find.byType(LinearProgressIndicator),
        );
        expect(
          tester.widget<LinearProgressIndicator>(bar).value,
          course.progress / 100,
        );
        expect(
          tester.getSemantics(bar).getSemanticsData().label,
          contains('Progresso do semestre em ${course.subject}'),
        );
      }
    },
  );

  testWidgets('trocar de aba preserva a posição de rolagem de Cursos', (
    tester,
  ) async {
    await openCourses(tester);
    final screen = tester.element(find.byType(CoursesScreen));
    await tester.ensureVisible(find.widgetWithText(Card, 'Cálculo Numérico'));
    await tester.pumpAndSettle();
    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(CoursesScreen),
        matching: find.byType(Scrollable),
      ),
    );
    final offset = scrollable.position.pixels;
    expect(offset, greaterThan(0));
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cursos'));
    await tester.pumpAndSettle();

    expect(tester.element(find.byType(CoursesScreen)), same(screen));
    expect(scrollable.position.pixels, offset);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
  });

  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(360, 640),
  ]) {
    testWidgets('todos os cards podem ser alcançados sem overflow em $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await openCourses(tester);

      for (final course in demoCourses) {
        final card = find.widgetWithText(Card, course.subject);
        await tester.ensureVisible(card);
        await tester.pumpAndSettle();
        expect(card.hitTestable(), findsOneWidget);
      }
      expect(find.text('Sala 108').hitTestable(), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
