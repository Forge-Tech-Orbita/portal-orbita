import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/models/learning_material.dart';
import 'package:portal_orbita/core/widgets/account_avatar.dart';
import 'package:portal_orbita/core/widgets/material_tile.dart';
import 'package:portal_orbita/core/widgets/materials_board.dart';
import 'package:portal_orbita/features/materials/presentation/new_material_screen.dart';

import 'helpers.dart';

const _options = <AudienceOption>[
  (label: 'ESW-412-N · Inteligência Artificial', audiences: ['ESW-412-N']),
  (label: 'ESW-430-N · Aprendizado de Máquina', audiences: ['ESW-430-N']),
];

const _materials = [
  LearningMaterial(
    id: 'a',
    title: 'Notas de aula',
    details: 'PDF',
    kind: MaterialKind.pdf,
    audiences: ['ESW-412-N'],
  ),
  LearningMaterial(
    id: 'b',
    title: 'Curso de ML',
    details: 'Link',
    kind: MaterialKind.link,
    audiences: ['ESW-430-N'],
  ),
];

void main() {
  test('link do material precisa começar com http(s)://', () {
    expect(validateMaterialUrl(''), 'Informe o endereço do link.');
    expect(
      validateMaterialUrl('exemplo.org'),
      'Use um link começando com http(s)://',
    );
    expect(validateMaterialUrl('https://exemplo.org/aula'), isNull);
  });

  testWidgets('novo material devolve o material publicado', (tester) async {
    PublishedMaterial? published;
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute<PublishedMaterial>(
                    builder: (_) => const NewMaterialScreen(
                      audienceLabel: 'Para qual turma',
                      audienceOptions: _options,
                      author: 'Prof. R. Nakamura',
                    ),
                  ),
                );
                published = result;
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tapVisible(tester, find.text('abrir'));
    expect(find.text('Para qual turma'), findsOneWidget);

    await tapVisible(tester, find.text('Publicar material'));
    expect(find.text('Informe o título do material.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Busca A*');
    await tapVisible(tester, find.text('Publicar material'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(published?.material.title, 'Busca A*');
    expect(published?.material.audiences, ['ESW-412-N']);
    expect(published?.material.kind, MaterialKind.pdf);
    expect(published?.notify, isTrue);
  });

  testWidgets('quadro de materiais filtra por público', (tester) async {
    var created = 0;
    await pumpScreen(
      tester,
      Scaffold(
        body: MaterialsBoard(
          subtitle: 'Visível só para os alunos das turmas escolhidas',
          filters: const ['ESW-412-N', 'ESW-430-N'],
          materials: _materials,
          onNewMaterial: () => created++,
        ),
      ),
    );
    expect(find.byType(MaterialTile), findsNWidgets(2));
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'ESW-430-N'));
    expect(find.byType(MaterialTile), findsOneWidget);
    await tapVisible(tester, find.text('Novo material'));
    expect(created, 1);
  });

  testWidgets('avatar da conta abre o menu de sessão', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(
        body: Center(
          child: AccountAvatar(
            initials: 'RN',
            name: 'Prof. R. Nakamura',
            role: 'Professor',
          ),
        ),
      ),
    );
    await tapVisible(tester, find.byTooltip('Conta'));
    expect(find.text('Prof. R. Nakamura'), findsOneWidget);
    expect(find.text('Encerrar sessão'), findsOneWidget);
  });
}
