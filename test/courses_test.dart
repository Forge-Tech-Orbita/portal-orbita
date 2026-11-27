import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/mock/academic_demo.dart';
import 'package:portal_orbita/features/courses/data/courses_mock.dart';
import 'package:portal_orbita/features/courses/presentation/courses_screen.dart';
import 'package:portal_orbita/features/materials/presentation/materials_screen.dart';

import 'helpers.dart';

void main() {
  test('fixtures têm as quatro disciplinas do semestre', () {
    expect(
      demoCourses.map(
        (c) => (c.subject, c.professor, c.credits, c.progress, c.room),
      ),
      [
        ('Arquitetura de Software', 'Prof. F. Ramalho', 4, 78, 'Sala 210'),
        ('Inteligência Artificial', 'Prof. R. Nakamura', 4, 70, 'Sala 304'),
        ('Banco de Dados II', 'Prof.ª L. Andrade', 3, 65, 'Lab 05'),
        ('Engenharia de Requisitos', 'Prof.ª C. Bezerra', 4, 82, 'Sala 212'),
      ],
    );
  });

  testWidgets('cards mostram créditos, progresso e sala', (tester) async {
    await loginAs(tester);
    await tester.tap(find.text('Cursos'));
    await tester.pumpAndSettle();

    expect(find.text('SEMESTRE 2026.2 · ATUAL'), findsOneWidget);
    expect(find.text('Minhas disciplinas'), findsOneWidget);
    expect(find.text('4 créditos'), findsNWidgets(3));
    expect(find.text('3 créditos'), findsOneWidget);
    final bars = tester.widgetList<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bars.map((bar) => bar.value), [0.78, 0.70, 0.65, 0.82]);
  });

  testWidgets('ver materiais abre os materiais das disciplinas', (
    tester,
  ) async {
    await loginAs(tester);
    await tester.tap(find.text('Cursos'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('ver materiais'));
    expect(find.byType(MaterialsScreen), findsOneWidget);
  });

  for (final size in testViewports) {
    testWidgets('disciplinas de ADM alcançáveis com texto 2× em $size', (
      tester,
    ) async {
      useViewport(tester, size, textScale: 2);
      await pumpScreen(
        tester,
        Scaffold(
          body: CoursesScreen(courses: coursesFor(AcademicDemo.administration)),
        ),
      );
      await tester.ensureVisible(find.text('Sala 103'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
    testWidgets('último card alcançável sem overflow em $size', (tester) async {
      useViewport(tester, size, textScale: 1.5);
      await pumpScreen(
        tester,
        const Scaffold(body: CoursesScreen(courses: demoCourses)),
      );
      await tester.ensureVisible(find.text('Sala 212'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
