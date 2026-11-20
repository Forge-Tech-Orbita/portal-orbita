import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/models/learning_material.dart';
import 'package:portal_orbita/core/widgets/info_banner.dart';
import 'package:portal_orbita/core/widgets/info_card.dart';
import 'package:portal_orbita/core/widgets/labeled_field.dart';
import 'package:portal_orbita/core/widgets/material_tile.dart';
import 'package:portal_orbita/core/widgets/metric_tile.dart';
import 'package:portal_orbita/core/widgets/orbit_logo.dart';
import 'package:portal_orbita/core/widgets/orbita_bottom_nav.dart';
import 'package:portal_orbita/core/theme/orbita_theme.dart';
import 'package:portal_orbita/core/widgets/page_heading.dart';
import 'package:portal_orbita/core/widgets/status_tag.dart';

import 'helpers.dart';

const _link = LearningMaterial(
  id: 'c4',
  title: 'Documentação do C4 Model',
  details: 'Prof. F. Ramalho',
  kind: MaterialKind.link,
  audiences: ['Arquitetura'],
);

void main() {
  test('saudação respeita manhã, tarde e noite', () {
    expect(greetingForHour(9), 'Bom dia');
    expect(greetingForHour(14), 'Boa tarde');
    expect(greetingForHour(20), 'Boa noite');
  });

  testWidgets('cabeçalhos mostram sobretítulo em caixa alta e ação', (
    tester,
  ) async {
    var actions = 0;
    await pumpScreen(
      tester,
      Scaffold(
        body: Column(
          children: [
            const PageHeading(
              overline: 'Horário semanal',
              title: 'Suas aulas',
              subtitle: 'Grade da turma',
            ),
            SectionHeader(
              title: 'Mural recente',
              actionLabel: 'ver tudo',
              onAction: () => actions++,
            ),
          ],
        ),
      ),
    );
    expect(find.text('HORÁRIO SEMANAL'), findsOneWidget);
    expect(find.text('Grade da turma'), findsOneWidget);
    await tester.tap(find.text('ver tudo'));
    expect(actions, 1);
  });

  testWidgets('cartões, etiquetas e faixas exibem textos e ações', (
    tester,
  ) async {
    var opened = 0;
    await pumpScreen(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const OrbitLogo(tagline: 'PORTAL ADMINISTRATIVO'),
              const MetricTile(value: '91%', label: 'Frequência'),
              const StatusTag(label: 'Em análise', tone: TagTone.warning),
              const InfoBanner(title: 'Simulação', message: 'Sem valor'),
              InfoCard(
                title: 'Financeiro',
                subtitle: 'Mensalidades',
                showChevron: true,
                onTap: () => opened++,
              ),
              const LabeledField(label: 'Matrícula', child: TextField()),
              MaterialTile(material: _link, onOpen: () => opened++),
            ],
          ),
        ),
      ),
    );
    for (final text in [
      'PORTAL ADMINISTRATIVO',
      '91%',
      'Em análise',
      'Simulação',
      'Matrícula',
      'Link',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.text('Financeiro'));
    await tester.tap(find.text('Abrir link'));
    expect(opened, 2);
  });

  testWidgets('cartão com texto 2× não transborda', (tester) async {
    useViewport(tester, const Size(360, 640), textScale: 2);
    await pumpScreen(
      tester,
      const Scaffold(
        body: InfoCard(
          title: 'Chamado #2026-0412 · Histórico escolar',
          subtitle: 'Aberto em 12/11 · em análise',
          trailing: StatusTag(label: 'Em análise', tone: TagTone.warning),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('barra inferior aceita itens de outro perfil e tema escuro', (
    tester,
  ) async {
    int? tapped;
    await pumpScreen(
      tester,
      Scaffold(
        bottomNavigationBar: OrbitaBottomNav(
          currentIndex: 0,
          dark: true,
          onTap: (index) => tapped = index,
          items: const [
            (icon: Icons.home_outlined, label: 'Painel'),
            (icon: Icons.shield_outlined, label: 'Permissões'),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Permissões'));
    expect(tapped, 1);
    final bar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bar.backgroundColor, OrbitaTheme.text);
    expect(studentNavItems.map((item) => item.label), [
      'Início',
      'Horário',
      'Notas',
      'Cursos',
      'Mais',
    ]);
  });
}
