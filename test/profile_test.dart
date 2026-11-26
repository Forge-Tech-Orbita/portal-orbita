import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portal_orbita/core/mock/student_mock.dart';
import 'package:portal_orbita/core/models/student_profile.dart';
import 'package:portal_orbita/core/widgets/student_id_card.dart';
import 'package:portal_orbita/features/auth/presentation/login_screen.dart';
import 'package:portal_orbita/features/navigation/presentation/main_navigation_screen.dart';
import 'package:portal_orbita/features/profile/presentation/edit_profile_screen.dart';
import 'package:portal_orbita/features/profile/presentation/profile_screen.dart';
import 'package:portal_orbita/features/support/presentation/support_screen.dart';

import 'fake_auth_repository.dart';
import 'helpers.dart';

final transparentPixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

Finder switchFor(String label) => find.widgetWithText(SwitchListTile, label);

Future<void> openEdit(WidgetTester tester) async {
  await tapVisible(tester, find.text('Editar dados pessoais'));
}

Future<void> save(WidgetTester tester) async {
  await tapVisible(tester, find.text('Salvar alterações'));
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
}

Finder fieldFor(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
  matching: find.byType(TextFormField),
);

void main() {
  group('validações de dados pessoais', () {
    test('telefone exige DDD e 10 ou 11 dígitos', () {
      expect(validatePhone(''), 'Informe o telefone com DDD.');
      expect(validatePhone('1234'), 'Use DDD + número, com 10 ou 11 dígitos.');
      expect(validatePhone('(11) 98765-4321'), isNull);
      expect(formatPhone('11987654321'), '(11) 98765-4321');
      expect(formatPhone('1132654321'), '(11) 3265-4321');
    });

    test('máscara oculta dígitos centrais do telefone', () {
      expect(maskPhone('(11) 98765-4521'), '(11) 9••••-4521');
      expect(maskPhone('(11) 3265-4321'), '(11) 3•••-4321');
      expect(maskPhone('inválido'), 'inválido');
    });

    test('e-mail pessoal é opcional e não pode ser institucional', () {
      expect(validatePersonalEmail(''), isNull);
      expect(validatePersonalEmail('x@'), 'Informe um e-mail válido.');
      expect(
        validatePersonalEmail('marina@orbita.edu'),
        'Use um e-mail pessoal, não o institucional.',
      );
      expect(validatePersonalEmail('marina@email.com'), isNull);
    });

    test('CEP é opcional e tem 8 dígitos', () {
      expect(validatePostalCode(''), isNull);
      expect(validatePostalCode('0131'), 'O CEP tem 8 dígitos.');
      expect(validatePostalCode('01310100'), isNull);
      expect(formatPostalCode('01310100'), '01310-100');
    });
  });

  testWidgets('perfil mostra conta, dados mascarados e preferências', (
    tester,
  ) async {
    await pumpScreen(tester, const ProfileScreen(isWeb: false));

    expect(find.text('CONTA'), findsOneWidget);
    expect(
      tester.widget<StudentIdCard>(find.byType(StudentIdCard)).compact,
      isTrue,
    );
    expect(find.text(demoStudent.maskedCpf), findsOneWidget);
    expect(find.text(demoStudent.email), findsOneWidget);
    expect(find.text('(11) 9••••-4521'), findsOneWidget);
    // O antigo "Modo escuro" deu lugar ao seletor de tema.
    expect(switchFor('Modo escuro'), findsNothing);

    await tapVisible(tester, switchFor('Notificações push'));
    expect(
      tester.widget<SwitchListTile>(switchFor('Notificações push')).value,
      isFalse,
    );
    await tapVisible(tester, switchFor('Biometria'));
    expect(
      tester.widget<SwitchListTile>(switchFor('Biometria')).value,
      isFalse,
    );
  });

  testWidgets('na Web a biometria fica desligada e bloqueada', (tester) async {
    await pumpScreen(tester, const ProfileScreen(isWeb: true));
    final biometrics = tester.widget<SwitchListTile>(switchFor('Biometria'));
    expect(biometrics.value, isFalse);
    expect(biometrics.onChanged, isNull);
  });

  testWidgets('editar dados valida, salva e atualiza o perfil', (tester) async {
    await pumpScreen(tester, const ProfileScreen(isWeb: false));
    await openEdit(tester);

    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(
      find.text('Nome, CPF e matrícula só mudam pela secretaria'),
      findsOne,
    );
    final name = tester.widget<TextFormField>(fieldFor('Nome'));
    expect(name.enabled, isFalse);
    expect(find.text(demoStudent.personalEmail), findsOneWidget);
    expect(find.text(demoStudent.address), findsOneWidget);

    await tester.enterText(fieldFor('Telefone'), '12');
    await tester.enterText(fieldFor('E-mail pessoal'), 'marina@orbita.edu');
    await save(tester);
    expect(
      find.text('Use DDD + número, com 10 ou 11 dígitos.'),
      findsOneWidget,
    );
    expect(
      find.text('Use um e-mail pessoal, não o institucional.'),
      findsOneWidget,
    );

    await tester.enterText(fieldFor('Telefone'), '21912345678');
    await tester.enterText(fieldFor('E-mail pessoal'), 'marina@exemplo.com');
    await save(tester);
    expect(find.byType(EditProfileScreen), findsNothing);
    expect(find.text('(21) 9••••-5678'), findsOneWidget);
    expect(find.text('Dados pessoais atualizados.'), findsOneWidget);

    await openEdit(tester);
    expect(find.text('(21) 91234-5678'), findsOneWidget);
    expect(find.text('marina@exemplo.com'), findsOneWidget);
  });

  test('perfil lê contato opcional e rejeita tipos inválidos', () {
    const base = {
      'nome': 'Aluno',
      'matricula': '202600001',
      'instituicaoId': 'inst-demo',
      'cursoId': null,
      'semestreLetivo': '2026-2',
      'periodo': 4,
    };
    final empty = StudentProfile.fromMap('u1', base);
    expect(empty.phone, isEmpty);
    expect(empty.address, isEmpty);
    final filled = StudentProfile.fromMap('u1', {
      ...base,
      'telefone': '(11) 91234-5678',
      'emailPessoal': 'a@b.com',
      'cep': '01310-100',
      'endereco': 'Rua A, 1',
    });
    expect(filled.student.phone, '(11) 91234-5678');
    expect(filled.student.personalEmail, 'a@b.com');
    expect(filled.student.postalCode, '01310-100');
    expect(filled.student.address, 'Rua A, 1');
    expect(
      () => StudentProfile.fromMap('u1', {...base, 'telefone': 1}),
      throwsFormatException,
    );
  });

  testWidgets('dados de contato são persistidos e relidos pelo perfil', (
    tester,
  ) async {
    final auth = await pumpTestApp(tester);
    await tester.enterText(
      find.byType(TextFormField).first,
      auth.profile.registration,
    );
    await tester.enterText(find.byType(TextFormField).last, 'test-only');
    await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    await openFromMore(tester, 'Meu perfil');
    expect(find.text('Não informado'), findsWidgets);

    await openEdit(tester);
    await tester.enterText(fieldFor('Telefone'), '21912345678');
    await tester.enterText(fieldFor('E-mail pessoal'), 'a@exemplo.com');
    await tester.enterText(fieldFor('CEP'), '01310100');
    await tester.enterText(fieldFor('Endereço'), 'Rua A, 1');
    await save(tester);

    expect(auth.saveContactCalls, 1);
    expect(auth.profile.phone, '(21) 91234-5678');
    expect(auth.profile.personalEmail, 'a@exemplo.com');
    expect(auth.profile.postalCode, '01310-100');
    expect(auth.profile.address, 'Rua A, 1');
    expect(find.text('(21) 9••••-5678'), findsOneWidget);
    expect(find.text('Dados pessoais atualizados.'), findsOneWidget);
  });

  testWidgets('falha ao persistir mantém a edição aberta com aviso', (
    tester,
  ) async {
    final auth = FakeAuthRepository()..failSaveContact = true;
    await pumpTestApp(tester, repository: auth);
    await tester.enterText(
      find.byType(TextFormField).first,
      auth.profile.registration,
    );
    await tester.enterText(find.byType(TextFormField).last, 'test-only');
    await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    await openFromMore(tester, 'Meu perfil');
    await openEdit(tester);
    await tester.enterText(fieldFor('Telefone'), '21912345678');
    await save(tester);

    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(
      find.text('Não foi possível salvar os dados. Tente novamente.'),
      findsOneWidget,
    );
    expect(auth.profile.phone, isEmpty);
  });

  testWidgets('cancelar a edição mantém os dados', (tester) async {
    await pumpScreen(tester, const ProfileScreen(isWeb: false));
    await openEdit(tester);
    await tester.enterText(fieldFor('Telefone'), '21912345678');
    await tapVisible(tester, find.text('Cancelar'));
    expect(find.text('(11) 9••••-4521'), findsOneWidget);
  });

  testWidgets('foto escolhida aparece na carteirinha e pode ser removida', (
    tester,
  ) async {
    ImageSource? requested;
    await pumpScreen(
      tester,
      ProfileScreen(
        isWeb: false,
        pickPhoto: (source) async {
          requested = source;
          return XFile.fromData(transparentPixel, mimeType: 'image/png');
        },
      ),
    );
    expect(
      tester.widget<StudentIdCard>(find.byType(StudentIdCard)).photo,
      isNull,
    );

    await openEdit(tester);
    await tapVisible(tester, find.text('Adicionar foto'));
    await tapVisible(tester, find.text('Tirar foto'));
    expect(requested, ImageSource.camera);
    expect(find.text('Foto de perfil atualizada.'), findsOneWidget);
    expect(find.text('Trocar foto'), findsOneWidget);
    await save(tester);
    expect(
      tester.widget<StudentIdCard>(find.byType(StudentIdCard)).photo,
      isA<MemoryImage>(),
    );

    await openEdit(tester);
    await tapVisible(tester, find.text('Trocar foto'));
    await tapVisible(tester, find.text('Remover foto'));
    await save(tester);
    expect(
      tester.widget<StudentIdCard>(find.byType(StudentIdCard)).photo,
      isNull,
    );
  });

  testWidgets('falha ao carregar foto mostra orientação', (tester) async {
    await pumpScreen(
      tester,
      ProfileScreen(
        isWeb: false,
        pickPhoto: (_) async => throw Exception('sem permissão'),
      ),
    );
    await openEdit(tester);
    await tapVisible(tester, find.text('Adicionar foto'));
    await tapVisible(tester, find.text('Escolher da galeria'));
    expect(
      find.text('Não foi possível carregar a foto. Verifique as permissões.'),
      findsOneWidget,
    );
  });

  testWidgets('correção de nome ou CPF leva ao suporte', (tester) async {
    await loginAs(tester);
    await openFromMore(tester, 'Meu perfil');
    await openEdit(tester);
    await tapVisible(tester, find.text('Corrigir nome ou CPF com o suporte'));
    expect(find.byType(SupportScreen), findsOneWidget);
  });

  testWidgets('encerrar sessão volta ao login sem histórico', (tester) async {
    await loginAs(tester);
    await openFromMore(tester, 'Meu perfil');
    await tapVisible(tester, find.text('Encerrar sessão'));

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
      find.byType(MainNavigationScreen, skipOffstage: false),
      findsNothing,
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(await navigator.maybePop(), isFalse);
  });

  for (final size in testViewports) {
    testWidgets('perfil e edição sem overflow em $size', (tester) async {
      useViewport(tester, size, textScale: 2);
      await pumpScreen(tester, const ProfileScreen(isWeb: false));
      await tester.ensureVisible(find.text('Encerrar sessão'));
      await tester.pumpAndSettle();
      await openEdit(tester);
      await tester.ensureVisible(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
