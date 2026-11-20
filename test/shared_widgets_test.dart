import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/mock/notices_mock.dart';
import 'package:portal_orbita/core/mock/student_mock.dart';
import 'package:portal_orbita/core/models/learning_material.dart';
import 'package:portal_orbita/core/widgets/decorative_barcode.dart';
import 'package:portal_orbita/core/widgets/material_tile.dart';
import 'package:portal_orbita/core/widgets/notice_tile.dart';
import 'package:portal_orbita/core/widgets/student_id_card.dart';

import 'helpers.dart';

Future<void> pumpComponent(WidgetTester tester, Widget child) {
  return pumpScreen(
    tester,
    Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

const _material = LearningMaterial(
  id: 'm',
  title: 'Manual do Aluno 2026',
  details: 'Coordenação',
  kind: MaterialKind.pdf,
  audiences: ['Curso'],
);

void main() {
  test('estudante tem dados e máscaras do protótipo', () {
    expect(demoStudent.name, 'Marina Duarte Costa');
    expect(demoStudent.registration, '2023104567');
    expect(demoStudent.maskedCpf, '•••.•••.•••-45');
    expect(demoStudent.maskedPhone, '(11) 9••••-4521');
    expect(demoStudent.phone, '(11) 98765-4521');
  });

  testWidgets('carteirinha completa mostra matrícula, validade e barras', (
    tester,
  ) async {
    await pumpComponent(tester, const StudentIdCard(student: demoStudent));
    expect(find.text('INSTITUTO ÓRBITA'), findsOneWidget);
    expect(find.text('ATIVO'), findsOneWidget);
    expect(find.text('Engenharia de Software · 6º período'), findsOneWidget);
    expect(find.text('2023104567'), findsOneWidget);
    expect(find.text('12/2027'), findsOneWidget);
    expect(find.byType(DecorativeBarcode), findsOneWidget);
  });

  testWidgets('carteirinha compacta omite metadados', (tester) async {
    await pumpComponent(
      tester,
      const StudentIdCard(student: demoStudent, compact: true),
    );
    expect(find.text('Engenharia de Software'), findsOneWidget);
    expect(find.text('2023104567'), findsNothing);
    expect(find.byType(DecorativeBarcode), findsNothing);
  });

  testWidgets('aviso compacto usa título curto, resumo e etiqueta', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      NoticeTile(notice: recentNotices.first, compact: true),
    );
    expect(find.text('Matrícula 2027.1'), findsOneWidget);
    expect(find.text('Inscrições abrem em 01/12 às 8h'), findsOneWidget);
    expect(find.text('Acadêmico'), findsOneWidget);
  });

  testWidgets('material em PDF mostra etiqueta e ação de abrir', (
    tester,
  ) async {
    var opened = 0;
    await pumpComponent(
      tester,
      MaterialTile(material: _material, onOpen: () => opened++),
    );
    expect(find.text('PDF'), findsOneWidget);
    await tapVisible(tester, find.text('Abrir PDF'));
    expect(opened, 1);
  });
}
