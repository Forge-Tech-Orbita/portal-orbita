import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/mock/notices_mock.dart';
import 'package:portal_orbita/core/mock/student_mock.dart';
import 'package:portal_orbita/core/models/learning_material.dart';
import 'package:portal_orbita/core/theme/orbita_theme.dart';
import 'package:portal_orbita/core/widgets/decorative_barcode.dart';
import 'package:portal_orbita/core/widgets/info_banner.dart';
import 'package:portal_orbita/core/widgets/info_card.dart';
import 'package:portal_orbita/core/widgets/labeled_field.dart';
import 'package:portal_orbita/core/widgets/material_tile.dart';
import 'package:portal_orbita/core/widgets/metric_tile.dart';
import 'package:portal_orbita/core/widgets/notice_tile.dart';
import 'package:portal_orbita/core/widgets/orbit_logo.dart';
import 'package:portal_orbita/core/widgets/orbita_bottom_nav.dart';
import 'package:portal_orbita/core/widgets/page_heading.dart';
import 'package:portal_orbita/core/widgets/status_tag.dart';
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

  test('tema usa a paleta creme e verde-petróleo', () {
    final theme = OrbitaTheme.data;
    expect(theme.scaffoldBackgroundColor, OrbitaTheme.background);
    expect(theme.colorScheme.primary, OrbitaTheme.primary);
    expect(theme.cardTheme.color, OrbitaTheme.surface);
    expect(theme.cardTheme.elevation, 0);
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

  testWidgets('componentes básicos exibem seus textos', (tester) async {
    var tapped = 0;
    await pumpComponent(
      tester,
      Column(
        children: [
          const OrbitLogo(),
          const PageHeading(
            overline: 'Atalhos',
            title: 'Mais',
            subtitle: 'sub',
          ),
          SectionHeader(title: 'Seção', actionLabel: 'ver', onAction: () {}),
          const MetricTile(value: '12', label: 'Alunos'),
          const StatusTag(label: 'Risco', tone: TagTone.danger),
          const InfoBanner(title: 'Aviso', message: 'Mensagem'),
          InfoCard(title: 'Card', subtitle: 'detalhe', onTap: () => tapped++),
          const LabeledField(label: 'Rótulo', child: TextField()),
          MaterialTile(material: _material, onOpen: () => tapped++),
        ],
      ),
    );
    for (final text in [
      'ÓRBITA',
      'ATALHOS',
      'Seção',
      '12',
      'Risco',
      'Aviso',
      'Card',
      'Rótulo',
      'PDF',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    await tester.tap(find.text('Card'));
    await tapVisible(tester, find.text('Abrir PDF'));
    expect(tapped, 2);
  });

  testWidgets('barra inferior aceita itens próprios e variante escura', (
    tester,
  ) async {
    int? selected;
    await pumpScreen(
      tester,
      Scaffold(
        bottomNavigationBar: OrbitaBottomNav(
          currentIndex: 0,
          onTap: (index) => selected = index,
          dark: true,
          items: const [
            (icon: Icons.dashboard_outlined, label: 'Painel'),
            (icon: Icons.group_outlined, label: 'Usuários'),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Usuários'));
    expect(selected, 1);
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .backgroundColor,
      OrbitaTheme.text,
    );
  });
}
