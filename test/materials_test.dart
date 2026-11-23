import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/widgets/material_tile.dart';
import 'package:portal_orbita/features/materials/data/student_materials_mock.dart';
import 'package:portal_orbita/features/materials/presentation/materials_screen.dart';

import 'helpers.dart';

void main() {
  testWidgets('materiais listam PDFs e links e filtram por disciplina', (
    tester,
  ) async {
    await pumpScreen(tester, const MaterialsScreen());

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

  testWidgets('abrir material informa que é demonstrativo', (tester) async {
    await pumpScreen(tester, const MaterialsScreen());
    await tapVisible(tester, find.text('Abrir link'));
    expect(find.textContaining('abre após a integração'), findsOneWidget);
  });

  for (final size in testViewports) {
    testWidgets('materiais sem overflow em $size', (tester) async {
      useViewport(tester, size, textScale: 2);
      await pumpScreen(tester, const MaterialsScreen());
      await tester.ensureVisible(find.text('Manual do Aluno 2026'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
