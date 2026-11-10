import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/features/more/presentation/more_screen.dart';

Future<void> openMore(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  await tester.ensureVisible(find.text('ENTRAR NO PORTAL'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Mais'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('menu mostra somente as seis opções e descrições do legado', (
    tester,
  ) async {
    await openMore(tester);
    expect(find.text('NAVEGAÇÃO'), findsOneWidget);
    expect(find.text('Mais opções'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNWidgets(6));
    for (final (label, description) in [
      ('Financeiro', 'Boletos e pagamentos'),
      ('Biblioteca', 'Empréstimos e acervo'),
      ('Mural', 'Avisos e comunicados'),
      ('Perfil', 'Dados e configurações'),
      ('Suporte', 'Central de ajuda'),
      ('Sair', 'Encerrar sessão'),
    ]) {
      final button = find.widgetWithText(OutlinedButton, label);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: button, matching: find.text(description)),
        findsOneWidget,
      );
      expect(button.hitTestable(), findsOneWidget);
    }
    expect(find.textContaining('em migração'), findsNothing);
  });

  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(360, 640),
  ]) {
    testWidgets(
      'grade mantém duas colunas e seis botões alcançáveis em $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await openMore(tester);
        final buttons = find.descendant(
          of: find.byType(MoreScreen),
          matching: find.byType(OutlinedButton),
        );
        expect(buttons, findsNWidgets(6));
        for (var index = 0; index < 6; index += 2) {
          final left = buttons.at(index);
          final right = buttons.at(index + 1);
          expect(tester.getTopLeft(left).dy, tester.getTopLeft(right).dy);
          expect(
            tester.getTopLeft(right).dx,
            greaterThan(tester.getTopRight(left).dx),
          );
          await tester.ensureVisible(left);
          await tester.pumpAndSettle();
          expect(left.hitTestable(), findsOneWidget);
          expect(right.hitTestable(), findsOneWidget);
        }
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'textos ampliados continuam roláveis sem altura fixa ou overflow',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openMore(tester);

      for (final label in [
        'Financeiro',
        'Biblioteca',
        'Mural',
        'Perfil',
        'Suporte',
        'Sair',
      ]) {
        final button = find.widgetWithText(OutlinedButton, label);
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        expect(button.hitTestable(), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
