import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/constants/app_routes.dart';
import 'package:portal_orbita/core/constants/institution_catalog.dart';
import 'package:portal_orbita/core/models/student_profile.dart';
import 'package:portal_orbita/features/auth/data/academic_session.dart';
import 'package:portal_orbita/features/auth/presentation/login_screen.dart';
import 'package:portal_orbita/features/home/presentation/widgets/next_class_card.dart';
import 'package:portal_orbita/features/navigation/presentation/main_navigation_screen.dart';
import 'package:portal_orbita/features/profile/presentation/course_selection_screen.dart';

import 'fake_auth_repository.dart';
import 'fake_grades_repository.dart';
import 'helpers.dart';

const profileWithoutCourse = StudentProfile(
  uid: 'first-access',
  name: 'Aluno Primeiro Acesso',
  registration: '202600001',
  institutionId: 'inst-demo',
  courseId: null,
  semester: '2026-2',
  period: 4,
);

Future<void> enterCredentials(
  WidgetTester tester, {
  String registration = '202600001',
}) async {
  await tester.enterText(find.byType(TextFormField).first, registration);
  await tester.enterText(find.byType(TextFormField).last, 'test-only');
}

void main() {
  testWidgets('Home e Horário usam a mesma grade com data fixa', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final session = AcademicSession(auth);
    addTearDown(auth.dispose);
    addTearDown(session.dispose);
    await tester.pump();
    session.profile = const StudentProfile(
      uid: 'adm',
      name: 'Aluno Fictício',
      registration: '202600002',
      institutionId: 'inst-demo',
      courseId: 'adm',
      semester: '2026-2',
      period: 4,
    );
    await pumpScreen(
      tester,
      AcademicSessionScope(
        session: session,
        child: MainNavigationScreen(
          gradesRepository: FakeGradesRepository(),
          now: DateTime(2026, 11, 19, 17),
        ),
      ),
    );
    expect(find.text('Marketing'), findsOneWidget);
    expect(find.text('Hoje · 19:00'), findsOneWidget);
    await tapVisible(tester, find.text('Horário'));
    expect(find.text('Marketing'), findsOneWidget);
    expect(
      find.textContaining('Grade da turma ADM-4N, 2026.2.'),
      findsOneWidget,
    );
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'QUA'));
    expect(find.text('Sem aulas em Quarta'), findsOneWidget);
  });

  testWidgets('semestre sem catálogo mostra estados vazios', (tester) async {
    final auth = await pumpTestApp(tester);
    auth.profile = const StudentProfile(
      uid: 'without-fixtures',
      name: 'Aluno Fictício',
      registration: '202600001',
      institutionId: 'inst-demo',
      courseId: 'adm',
      semester: '2027-1',
      period: 5,
    );
    await enterCredentials(tester);
    await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
    expect(find.byType(NextClassCard), findsNothing);
    await tapVisible(tester, find.text('Horário'));
    expect(
      find.text('Nenhuma grade demonstrativa para este perfil.'),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('Cursos'));
    expect(
      find.text('Nenhuma disciplina demonstrativa para este perfil.'),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('ver materiais'));
    expect(
      find.text('Nenhum material demonstrativo para este perfil.'),
      findsOneWidget,
    );
  });

  test('e-mail técnico preserva zeros e isola instituições', () {
    expect(
      technicalEmail('inst-demo', '0001'),
      'inst-demo.0001@auth.orbita.example',
    );
    expect(
      technicalEmail('inst-horizonte', '0001'),
      isNot(technicalEmail('inst-demo', '0001')),
    );
    for (final value in ['', '1.2', 'P2019', '1@x', '1 2', '１２']) {
      expect(() => technicalEmail('inst-demo', value), throwsFormatException);
    }
    expect(() => technicalEmail('desconhecida', '1'), throwsFormatException);
  });

  test('perfil valida contrato e não deduz curso da matrícula', () {
    final data = <String, dynamic>{
      'nome': 'Aluno Fictício',
      'matricula': '0001',
      'instituicaoId': 'inst-demo',
      'cursoId': null,
      'semestreLetivo': '2026-2',
      'periodo': 4,
    };
    final profile = StudentProfile.fromMap('uid-a', data);
    expect(profile.courseId, isNull);
    expect(profile.student.registration, '0001');
    expect(profile.student.institution, 'Sapiens — Demonstração');
    for (final entry in {
      'matricula': 1,
      'periodo': 4.5,
      'nome': '',
      'cursoId': 'outro',
      'semestreLetivo': '2026-3',
    }.entries) {
      expect(
        () =>
            StudentProfile.fromMap('uid-a', {...data, entry.key: entry.value}),
        throwsFormatException,
      );
    }
    expect(
      () => StudentProfile.fromMap('uid-a', {
        ...data,
        'instituicaoId': 'inst-horizonte',
        'cursoId': 'adm',
      }),
      throwsFormatException,
    );
  });

  testWidgets(
    'login começa vazio, tem instituição e não oferece biometria ou cadastro',
    (tester) async {
      await pumpTestApp(tester);
      expect(find.text('ÓRBITA'), findsOneWidget);
      expect(find.text('Instituição'), findsOneWidget);
      expect(find.text('Matrícula'), findsOneWidget);
      expect(find.text('Senha de acesso'), findsOneWidget);
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: find.byType(TextFormField).last,
                matching: find.byType(EditableText),
              ),
            )
            .obscureText,
        isTrue,
      );
      expect(find.text('Acessar com biometria'), findsNothing);
      expect(find.text('Criar conta'), findsNothing);
      await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
      expect(find.text('Senha obrigatória'), findsOneWidget);
      expect(find.textContaining('matrícula numérica'), findsOneWidget);
    },
  );

  testWidgets('loading impede login duplicado e limpa senha', (tester) async {
    final auth = FakeAuthRepository()..pendingSignIn = Completer<void>();
    await pumpTestApp(tester, repository: auth);
    await enterCredentials(tester);
    await tester.ensureVisible(find.text('ENTRAR NO PORTAL'));
    await tester.tap(find.text('ENTRAR NO PORTAL'));
    await tester.pump();
    expect(find.text('AUTENTICANDO...'), findsOneWidget);
    expect(auth.signInCalls, 1);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).last)
          .controller!
          .text,
      isEmpty,
    );
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    auth.pendingSignIn!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });

  testWidgets('falha no perfil não concede acesso nem volta ao protótipo', (
    tester,
  ) async {
    final auth = FakeAuthRepository()..failProfile = true;
    await pumpTestApp(tester, repository: auth);
    await enterCredentials(tester);
    await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
    expect(
      find.textContaining('Não foi possível carregar o perfil'),
      findsOneWidget,
    );
    expect(find.byType(MainNavigationScreen), findsNothing);
    Navigator.of(tester.element(find.byType(LoginScreen)))
        .pushNamed(AppRoutes.main);
    await tester.pumpAndSettle();
    expect(find.byType(MainNavigationScreen), findsNothing);
  });

  testWidgets('curso é escolhido uma vez antes de entrar na área do aluno', (
    tester,
  ) async {
    final auth = FakeAuthRepository()
      ..profile = const StudentProfile(
        uid: 'a',
        name: 'Ana Teste',
        registration: '202600001',
        institutionId: 'inst-demo',
        courseId: null,
        semester: '2026-2',
        period: 4,
      );
    await pumpTestApp(tester, repository: auth);
    await enterCredentials(tester);
    await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
    expect(find.byType(CourseSelectionScreen), findsOneWidget);
    expect(find.byType(MainNavigationScreen), findsNothing);
    await tester.tap(find.text('Administração'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(auth.profile.courseId, 'adm');
    expect(find.byType(MainNavigationScreen), findsOneWidget);
    await expectLater(auth.chooseCourse('a', 'si'), throwsStateError);
  });

  for (final size in testViewports) {
    testWidgets('seleção mostra somente cursos ativos com texto 2× em $size', (
      tester,
    ) async {
      useViewport(tester, size, textScale: 2);
      final auth = FakeAuthRepository()
        ..profile = profileWithoutCourse
        ..inactiveCourseIds.add('adm');
      await pumpTestApp(tester, repository: auth);
      await enterCredentials(tester);
      await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
      expect(find.byType(CourseSelectionScreen), findsOneWidget);
      expect(find.text('Sistemas de Informação'), findsOneWidget);
      expect(find.text('Administração'), findsNothing);
      final session = AcademicSessionScope.maybeOf(
        tester.element(find.byType(CourseSelectionScreen)),
      )!;
      await session.chooseCourse('adm');
      expect(auth.profile.courseId, isNull);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('catálogo vazio não oferece curso nem libera a área do aluno', (
    tester,
  ) async {
    final auth = FakeAuthRepository()
      ..profile = profileWithoutCourse
      ..inactiveCourseIds.addAll(['si', 'adm']);
    await pumpTestApp(tester, repository: auth);
    await enterCredentials(tester);
    await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
    expect(
      find.textContaining('Nenhum curso ativo disponível'),
      findsOneWidget,
    );
    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(MainNavigationScreen), findsNothing);
  });

  testWidgets('falha no catálogo não usa os cursos locais como fallback', (
    tester,
  ) async {
    final auth = FakeAuthRepository()
      ..profile = profileWithoutCourse
      ..failCourses = true;
    await pumpTestApp(tester, repository: auth);
    await enterCredentials(tester);
    await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
      find.textContaining('Não foi possível carregar o perfil'),
      findsOneWidget,
    );
    expect(find.byType(CourseSelectionScreen), findsNothing);
    expect(find.byType(MainNavigationScreen), findsNothing);
  });

  test('logout descarta catálogo atrasado da sessão anterior', () async {
    final pending = Completer<Set<String>>();
    final auth = FakeAuthRepository()
      ..profile = profileWithoutCourse
      ..pendingCourses = pending.future;
    final session = AcademicSession(auth);
    addTearDown(session.dispose);
    addTearDown(auth.dispose);
    await Future<void>.delayed(Duration.zero);
    await session.signIn('inst-demo', '202600001', 'test-only');
    await Future<void>.delayed(Duration.zero);
    expect(session.loading, isTrue);
    await session.signOut();
    pending.complete({'si', 'adm'});
    await Future<void>.delayed(Duration.zero);
    expect(session.profile, isNull);
    expect(session.activeCourseIds, isEmpty);
  });

  testWidgets(
    'instituição selecionada determina a conta com a mesma matrícula',
    (tester) async {
      final auth = FakeAuthRepository()
        ..profile = const StudentProfile(
          uid: 'h',
          name: 'Aluno Horizonte',
          registration: '202600001',
          institutionId: 'inst-horizonte',
          courseId: 'si',
          semester: '2026-2',
          period: 4,
        );
      await pumpTestApp(tester, repository: auth);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Instituto Horizonte — Demonstração').last);
      await tester.pumpAndSettle();
      await enterCredentials(tester);
      await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
      expect(find.text('Aluno Horizonte'), findsWidgets);
      expect(find.textContaining('Marina'), findsNothing);
      expect(find.byType(MainNavigationScreen), findsOneWidget);
    },
  );

  testWidgets('esqueci senha orienta responsável pelas contas', (tester) async {
    await pumpTestApp(tester);
    await tapVisible(tester, find.text('Esqueci minha senha'));
    expect(find.textContaining('Solicite a redefinição'), findsOneWidget);
  });

  testWidgets(
    'logout limpa a pilha, perfil e dados locais ao trocar de aluno',
    (tester) async {
      final auth = await pumpTestApp(tester);
      final siProfile = auth.profile;

      Future<void> checkCatalog({required bool adm}) async {
        final subjects = adm
            ? ['Gestão de Pessoas', 'Contabilidade Gerencial', 'Marketing']
            : [
                'Inteligência Artificial',
                'Banco de Dados II',
                'Arquitetura de Software',
                'Engenharia de Requisitos',
              ];
        final nextClass = tester.widget<NextClassCard>(
          find.byType(NextClassCard),
        );
        expect(nextClass.nextClass.subject, isIn(subjects));
        await tapVisible(tester, find.text('Horário'));
        await tapVisible(tester, find.widgetWithText(ChoiceChip, 'SEG'));
        expect(find.text(subjects.first), findsOneWidget);
        expect(find.textContaining(adm ? 'ADM-4N' : 'ESW-6N'), findsOneWidget);
        await tapVisible(tester, find.text('Cursos'));
        for (final subject in subjects) {
          expect(find.text(subject), findsOneWidget);
        }
        expect(
          find.text(adm ? 'Inteligência Artificial' : 'Marketing'),
          findsNothing,
        );
        await tapVisible(tester, find.text('ver materiais'));
        final filter = find.widgetWithText(
          ChoiceChip,
          adm ? 'Marketing' : 'IA',
        );
        expect(tester.widget<ChoiceChip>(filter).selected, isFalse);
        expect(
          find.widgetWithText(ChoiceChip, adm ? 'IA' : 'Marketing'),
          findsNothing,
        );
        await tapVisible(tester, filter);
        await tapVisible(tester, find.widgetWithText(ChoiceChip, 'PDF'));
        if (adm) {
          expect(
            find.text('Nenhum material para este filtro.'),
            findsOneWidget,
          );
          await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Link'));
          expect(find.text('Introdução à Pesquisa de Mercado'), findsOneWidget);
        } else {
          expect(find.text('Notas de aula · Busca heurística'), findsOneWidget);
        }
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      await enterCredentials(tester);
      await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
      await checkCatalog(adm: false);
      await openFromMore(tester, 'Meu perfil');
      expect(
        find.textContaining('Dados pessoais, foto e preferências são locais'),
        findsOneWidget,
      );
      await tapVisible(tester, find.text('Encerrar sessão'));
      expect(auth.signOutCalls, 1);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        find.byType(MainNavigationScreen, skipOffstage: false),
        findsNothing,
      );
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
        isFalse,
      );
      auth.profile = const StudentProfile(
        uid: 'student-b',
        name: 'Outro Aluno',
        registration: '202600002',
        institutionId: 'inst-demo',
        courseId: 'adm',
        semester: '2026-2',
        period: 4,
      );
      await enterCredentials(tester, registration: '202600002');
      await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
      expect(find.text('Outro Aluno'), findsWidgets);
      expect(find.text('Aluno Demonstração'), findsNothing);
      await checkCatalog(adm: true);

      await openFromMore(tester, 'Meu perfil');
      await tapVisible(tester, find.text('Encerrar sessão'));
      auth.profile = siProfile;
      await enterCredentials(tester);
      await tapVisible(tester, find.text('ENTRAR NO PORTAL'));
      await checkCatalog(adm: false);
    },
  );

  test(
    'logout descarta resposta atrasada do perfil e eventos tardios de login',
    () async {
      final auth = FakeAuthRepository()
        ..pendingProfile = Completer<StudentProfile>().future;
      final session = AcademicSession(auth);
      addTearDown(session.dispose);
      addTearDown(auth.dispose);
      await Future<void>.delayed(Duration.zero);
      final pending = Completer<StudentProfile>();
      auth.pendingProfile = pending.future;
      await session.signIn('inst-demo', '202600001', 'test-only');
      await Future<void>.delayed(Duration.zero);
      await session.signOut();
      pending.complete(auth.profile);
      await Future<void>.delayed(Duration.zero);
      expect(session.profile, isNull);
      auth.events.add((
        uid: auth.profile.uid,
        email: technicalEmail('inst-demo', '202600001'),
      ));
      await Future<void>.delayed(Duration.zero);
      expect(session.profile, isNull);
      expect(auth.signOutCalls, greaterThan(1));
    },
  );

  test(
    'troca de usuário ignora perfil anterior e dispose ignora respostas',
    () async {
      final auth = FakeAuthRepository();
      final session = AcademicSession(auth);
      await Future<void>.delayed(Duration.zero);
      final pending = Completer<StudentProfile>();
      auth.pendingProfile = pending.future;
      auth.events.add((uid: 'old', email: 'old'));
      await Future<void>.delayed(Duration.zero);
      auth.pendingProfile = null;
      auth.events.add((uid: auth.profile.uid, email: 'new'));
      await Future<void>.delayed(Duration.zero);
      expect(session.profile?.uid, auth.profile.uid);
      pending.complete(
        const StudentProfile(
          uid: 'old',
          name: 'Antigo',
          registration: '1',
          institutionId: 'inst-demo',
          courseId: 'si',
          semester: '2026-2',
          period: 4,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(session.profile?.uid, auth.profile.uid);
      final disposed = Completer<StudentProfile>();
      auth.pendingProfile = disposed.future;
      auth.events.add((uid: 'late', email: 'late'));
      await Future<void>.delayed(Duration.zero);
      session.dispose();
      disposed.complete(auth.profile);
      await Future<void>.delayed(Duration.zero);
      await auth.dispose();
    },
  );

  test('evento tardio de outro login não restaura a conta anterior', () async {
    final auth = FakeAuthRepository();
    final session = AcademicSession(auth);
    addTearDown(session.dispose);
    addTearDown(auth.dispose);
    await Future<void>.delayed(Duration.zero);
    await session.signIn('inst-demo', '202600001', 'test-only');
    await Future<void>.delayed(Duration.zero);
    auth.events.add((
      uid: 'old',
      email: technicalEmail('inst-horizonte', '202600001'),
    ));
    await Future<void>.delayed(Duration.zero);
    expect(session.profile, isNull);
    expect(auth.signOutCalls, 1);
  });

  test('falha ao sair limpa perfil e informa erro', () async {
    final auth = FakeAuthRepository();
    final session = AcademicSession(auth);
    addTearDown(session.dispose);
    addTearDown(auth.dispose);
    await Future<void>.delayed(Duration.zero);
    await session.signIn('inst-demo', '202600001', 'test-only');
    await Future<void>.delayed(Duration.zero);
    auth.failSignOut = true;
    await session.signOut();
    expect(session.profile, isNull);
    expect(session.error, contains('encerrar'));
  });

  for (final size in testViewports) {
    testWidgets('formulário com teclado não gera overflow em $size', (
      tester,
    ) async {
      useViewport(tester, size);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await pumpTestApp(tester);
      await tester.ensureVisible(find.text('ENTRAR NO PORTAL'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
