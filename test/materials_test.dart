import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/mock/academic_demo.dart';
import 'package:portal_orbita/core/widgets/material_tile.dart';
import 'package:portal_orbita/features/materials/data/student_materials_mock.dart';
import 'package:portal_orbita/features/materials/presentation/materials_screen.dart';

import 'helpers.dart';

Finder filterChip(String group, String label) => find.descendant(
  of: find.byKey(ValueKey('material-$group-filter')),
  matching: find.widgetWithText(ChoiceChip, label),
);

void main() {
  testWidgets('materiais listam PDFs e links e filtram por disciplina', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      MaterialsList(catalog: materialsFor(AcademicDemo.informationSystems)),
    );

    expect(
      find.byType(MaterialTile),
      findsNWidgets(demoStudentMaterials.length),
    );
    expect(find.text('Abrir link'), findsOneWidget);

    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'IA'));
    expect(find.byType(MaterialTile), findsNWidgets(2));

    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'BD II'));
    expect(find.text('Nenhum material para este filtro.'), findsOneWidget);
  });

  testWidgets('filtros de disciplina e tipo mantêm seleções independentes', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      MaterialsList(catalog: materialsFor(AcademicDemo.informationSystems)),
    );

    await tapVisible(tester, filterChip('discipline', 'IA'));
    await tapVisible(tester, filterChip('kind', 'PDF'));
    expect(find.byType(MaterialTile), findsNWidgets(2));
    expect(find.text('Manual do Aluno 2026'), findsNothing);

    await tapVisible(tester, filterChip('kind', 'Link'));
    expect(find.text('Nenhum material para este filtro.'), findsOneWidget);
    expect(find.byType(MaterialTile), findsNothing);

    await tapVisible(tester, filterChip('discipline', 'Arquitetura'));
    expect(find.text('Documentação do C4 Model'), findsOneWidget);
    expect(
      tester.widget<ChoiceChip>(filterChip('kind', 'Link')).selected,
      isTrue,
    );

    await tapVisible(tester, filterChip('discipline', 'Todos'));
    expect(find.byType(MaterialTile), findsOneWidget);
    await tapVisible(tester, filterChip('discipline', 'IA'));
    await tapVisible(tester, filterChip('kind', 'Todos'));
    expect(find.byType(MaterialTile), findsNWidgets(2));
    await tapVisible(tester, filterChip('discipline', 'Todos'));
    expect(
      find.byType(MaterialTile),
      findsNWidgets(demoStudentMaterials.length),
    );
  });

  testWidgets('abrir material informa que é demonstrativo', (tester) async {
    await pumpScreen(
      tester,
      MaterialsList(catalog: materialsFor(AcademicDemo.informationSystems)),
    );
    await tapVisible(tester, find.text('Abrir link'));
    expect(find.textContaining('abre após a integração'), findsOneWidget);
  });

  for (final size in testViewports) {
    testWidgets('materiais de ADM alcançáveis com texto 2× em $size', (
      tester,
    ) async {
      useViewport(tester, size, textScale: 2);
      await pumpScreen(
        tester,
        MaterialsList(catalog: materialsFor(AcademicDemo.administration)),
      );
      await tapVisible(tester, find.text('Abrir PDF').last);
      expect(find.textContaining('abre após a integração'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('materiais sem overflow em $size', (tester) async {
      useViewport(tester, size, textScale: 2);
      await pumpScreen(
        tester,
        MaterialsList(catalog: materialsFor(AcademicDemo.informationSystems)),
      );
      await tapVisible(tester, filterChip('discipline', 'Arquitetura'));
      await tapVisible(tester, filterChip('kind', 'Link'));
      await tapVisible(tester, find.text('Abrir link'));
      expect(find.textContaining('abre após a integração'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tapVisible(tester, filterChip('discipline', 'Todos'));
      await tapVisible(tester, filterChip('kind', 'PDF'));
      await tapVisible(tester, find.text('Abrir PDF').last);
      expect(find.textContaining('abre após a integração'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
