import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/features/home/presentation/home_screen.dart';
import 'package:portal_orbita/features/support/presentation/support_screen.dart';

const expectedSupportFaqs = [
  ('Como emito a 2ª via do boleto?', 'Acesse Financeiro → Gerar 2ª via.'),
  (
    'Como solicito o histórico escolar?',
    'Abra um chamado na Central de Suporte.',
  ),
  ('Onde vejo minha frequência?', 'Acesse Notas → detalhes da disciplina.'),
];

Future<void> openSupport(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  await tester.ensureVisible(find.text('ENTRAR NO PORTAL'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
  final shortcut = find.widgetWithText(OutlinedButton, 'Suporte');
  await tester.ensureVisible(shortcut);
  await tester.pumpAndSettle();
  await tester.tap(shortcut);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'central de suporte exibe card da secretaria e três FAQs na ordem original',
    (tester) async {
      await openSupport(tester);
      for (final text in [
        'Central de suporte',
        'Atendimento demonstrativo · sem abertura real de chamados',
        'FALE COM A SECRETARIA',
        'Abra um chamado para dúvidas sobre matrícula, documentos, aproveitamento de disciplinas ou requerimentos.',
        'Abrir novo chamado',
        'Perguntas frequentes',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      for (final (question, answer) in expectedSupportFaqs) {
        await tester.ensureVisible(find.text(answer));
        await tester.pumpAndSettle();
        expect(find.text(question), findsOneWidget);
        expect(find.text(answer), findsOneWidget);
      }
      final questions = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .where((text) => expectedSupportFaqs.any((faq) => faq.$1 == text));
      expect(questions, expectedSupportFaqs.map((faq) => faq.$1));
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.textContaining('em migração'), findsNothing);
    },
  );

  testWidgets(
    'Abrir novo chamado informa ausência de integração e preserva retorno',
    (tester) async {
      await openSupport(tester);
      final button = find.widgetWithText(FilledButton, 'Abrir novo chamado');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(
        find.text('Recurso demonstrativo, sem integração'),
        findsOneWidget,
      );
      expect(find.byType(SupportScreen), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );

  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(360, 640),
  ]) {
    testWidgets(
      'secretaria e perguntas frequentes alcançáveis sem overflow em $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await openSupport(tester);

        await tester.ensureVisible(find.text('Abrir novo chamado'));
        await tester.pumpAndSettle();
        expect(find.text('Abrir novo chamado').hitTestable(), findsOneWidget);
        for (final (question, answer) in expectedSupportFaqs) {
          await tester.ensureVisible(find.text(answer));
          await tester.pumpAndSettle();
          expect(find.text(question).hitTestable(), findsOneWidget);
          expect(find.text(answer).hitTestable(), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'texto ampliado mantém chamado e três FAQs legíveis por rolagem',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openSupport(tester);

      for (final target in [
        find.text('FALE COM A SECRETARIA'),
        find.text('Abrir novo chamado'),
        for (final (question, answer) in expectedSupportFaqs) ...[
          find.text(question),
          find.text(answer),
        ],
      ]) {
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
