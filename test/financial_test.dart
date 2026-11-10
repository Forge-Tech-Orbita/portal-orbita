import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/widgets/decorative_barcode.dart';
import 'package:portal_orbita/features/financial/data/financial_mock.dart';
import 'package:portal_orbita/features/financial/presentation/financial_screen.dart';

Future<void> openFinancial(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  await tester.ensureVisible(find.text('ENTRAR NO PORTAL'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
  final shortcut = find.widgetWithText(OutlinedButton, 'Financeiro');
  await tester.ensureVisible(shortcut);
  await tester.pumpAndSettle();
  await tester.tap(shortcut);
  await tester.pumpAndSettle();
}

void main() {
  test('fixtures preservam valores, vencimento e ordem do histórico', () {
    expect(
      (
        demoInvoice.label,
        demoInvoice.amount,
        demoInvoice.dueDate,
        demoInvoice.discount,
      ),
      ('MENSALIDADE · SETEMBRO', r'R$ 1.240,00', '10/09/2026', r'− R$ 62,00'),
    );
    expect(
      demoPayments.map((payment) => (payment.month, payment.amount)).toList(),
      [
        ('Agosto/2026', r'R$ 1.178,00'),
        ('Julho/2026', r'R$ 1.178,00'),
        ('Junho/2026', r'R$ 1.178,00'),
        ('Maio/2026', r'R$ 1.178,00'),
      ],
    );
  });

  testWidgets(
    'fatura exibe valores originais e quatro pagamentos demonstrativos',
    (tester) async {
      await openFinancial(tester);
      for (final text in [
        'Dados demonstrativos · sem integração financeira',
        'Fatura em aberto',
        'Vencimento em 10/09/2026',
        'MENSALIDADE · SETEMBRO',
        r'R$ 1.240,00',
        '10/09/2026',
        'Desconto pontualidade',
        r'− R$ 62,00',
        'Código decorativo · sem valor bancário',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      await tester.ensureVisible(find.text('Maio/2026'));
      await tester.pumpAndSettle();
      expect(find.text('Histórico de pagamentos'), findsOneWidget);
      expect(find.text(r'Pago · R$ 1.178,00'), findsNWidgets(4));
      final months = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .where(
            (text) => demoPayments.any((payment) => payment.month == text),
          );
      expect(months, ['Agosto/2026', 'Julho/2026', 'Junho/2026', 'Maio/2026']);
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    },
  );

  testWidgets(
    'Gerar 2ª via informa ausência de integração sem alterar pagamentos',
    (tester) async {
      await openFinancial(tester);
      final button = find.widgetWithText(FilledButton, 'Gerar 2ª via');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(
        find.text('Recurso demonstrativo, sem integração'),
        findsOneWidget,
      );
      expect(find.byType(FinancialScreen), findsOneWidget);
      expect(find.text('Fatura em aberto'), findsOneWidget);
      expect(find.text(r'R$ 1.240,00'), findsOneWidget);
      expect(find.text(r'Pago · R$ 1.178,00'), findsNWidgets(4));
    },
  );

  testWidgets('barras financeiras são decorativas e repetíveis', (
    tester,
  ) async {
    await openFinancial(tester);
    final barcode = find.byType(DecorativeBarcode);
    expect(tester.widget<DecorativeBarcode>(barcode).count, 46);
    final bars = find.descendant(
      of: barcode,
      matching: find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == 2,
      ),
    );
    expect(bars, findsNWidgets(46));
    final heights = tester
        .widgetList<SizedBox>(bars)
        .map((bar) => bar.height)
        .toList();
    final semantics = tester.widget<ExcludeSemantics>(
      find.descendant(of: barcode, matching: find.byType(ExcludeSemantics)),
    );
    expect(semantics.excluding, isTrue);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widgetList<SizedBox>(bars).map((bar) => bar.height), heights);
  });

  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(360, 640),
  ]) {
    testWidgets('fatura e histórico alcançáveis sem overflow em $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await openFinancial(tester);
      await tester.ensureVisible(find.text('Gerar 2ª via'));
      await tester.pumpAndSettle();
      expect(find.text('Gerar 2ª via').hitTestable(), findsOneWidget);
      final lastPayment = find.text(r'Pago · R$ 1.178,00').last;
      await tester.ensureVisible(lastPayment);
      await tester.pumpAndSettle();
      expect(lastPayment.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'texto ampliado mantém valores e pagamentos acessíveis por rolagem',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openFinancial(tester);

      for (final target in [
        find.text(r'R$ 1.240,00'),
        find.text(r'− R$ 62,00'),
        find.text('Gerar 2ª via'),
        find.text(r'Pago · R$ 1.178,00').last,
      ]) {
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
