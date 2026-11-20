import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/theme/orbita_theme.dart';

const testViewports = [Size(360, 800), Size(390, 844), Size(360, 640)];

/// Ajusta viewport e escala de texto, restaurando tudo no teardown.
void useViewport(WidgetTester tester, Size size, {double textScale = 1}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> pumpScreen(WidgetTester tester, Widget screen) {
  return tester.pumpWidget(MaterialApp(theme: OrbitaTheme.data, home: screen));
}

/// Abre o app e entra com a matrícula informada (padrão: aluna).
Future<void> loginAs(WidgetTester tester, [String? registration]) async {
  await tester.pumpWidget(const MainApp());
  if (registration != null) {
    await tester.enterText(find.byType(TextFormField).first, registration);
  }
  final enter = find.text('ENTRAR NO PORTAL');
  await tester.ensureVisible(enter);
  await tester.pumpAndSettle();
  await tester.tap(enter);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Abre uma opção da aba Mais do aluno.
Future<void> openFromMore(WidgetTester tester, String label) async {
  await tester.tap(find.text('Mais'));
  await tester.pumpAndSettle();
  await tapVisible(tester, find.text(label));
}

String? currentRouteName(WidgetTester tester, Type screen) =>
    ModalRoute.of(tester.element(find.byType(screen)))?.settings.name;
