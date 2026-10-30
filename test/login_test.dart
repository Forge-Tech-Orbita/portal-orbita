import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/features/auth/presentation/login_screen.dart';
import 'package:portal_orbita/features/home/presentation/home_screen.dart';
import 'package:portal_orbita/features/navigation/presentation/main_navigation_screen.dart';

void main() {
  testWidgets('exibe identidade, dados demonstrativos e senha oculta', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('ÓRBITA'), findsOneWidget);
    expect(find.text('ENSINO EM OUTRA ÓRBITA'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Símbolo orbital do Instituto Órbita'),
      findsOneWidget,
    );
    expect(find.textContaining('sem autenticação real'), findsOneWidget);
    expect(find.textContaining('CONEXÃO CRIPTOGRAFADA'), findsNothing);
    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].controller!.text, '2023104567');
    expect(fields[1].controller!.text, '••••••••');
    expect(fields[1].obscureText, isTrue);
  });

  testWidgets('valida campos obrigatórios sem inventar formato ou tamanho', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.enterText(find.byType(TextFormField).last, '');
    await tester.tap(find.text('ENTRAR NO PORTAL'));
    await tester.pumpAndSettle();

    expect(find.text('Informe a matrícula.'), findsOneWidget);
    expect(find.text('Informe a senha.'), findsOneWidget);
    expect(find.text('AUTENTICANDO...'), findsNothing);
    expect(find.byType(MainNavigationScreen), findsNothing);

    await tester.enterText(find.byType(TextFormField).first, 'A');
    await tester.tap(find.text('ENTRAR NO PORTAL'));
    await tester.pumpAndSettle();
    expect(find.text('Informe a matrícula.'), findsNothing);
    expect(find.text('Informe a senha.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, 'x');
    await tester.tap(find.text('ENTRAR NO PORTAL'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('loading bloqueia duplicidade e só entra após 900 ms', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    final submit = tester
        .widget<FilledButton>(find.byType(FilledButton))
        .onPressed!;
    submit();
    submit();
    await tester.pump();

    expect(find.text('AUTENTICANDO...'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
    for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.enabled, isFalse);
    }

    await tester.pump(const Duration(milliseconds: 899));
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainNavigationScreen), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen, skipOffstage: false), findsNothing);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
  });

  testWidgets('biometria explicitamente simulada usa o mesmo fluxo de acesso', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.tap(find.text('Acessar com biometria (simulada)'));
    await tester.pump();

    expect(find.text('AUTENTICANDO...'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
  });

  testWidgets('ação concluir do teclado também envia o formulário', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.showKeyboard(find.byType(TextFormField).last);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('AUTENTICANDO...'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('descartar Login durante espera não acessa estado desmontado', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.tap(find.text('ENTRAR NO PORTAL'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(MainNavigationScreen), findsNothing);
  });

  testWidgets('formulário rolável permite enviar em 360 × 640 com teclado', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MainApp());
    await tester.showKeyboard(find.byType(TextFormField).last);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.byType(FilledButton).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
