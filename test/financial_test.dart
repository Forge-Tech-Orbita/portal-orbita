import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/widgets/decorative_barcode.dart';
import 'package:portal_orbita/features/financial/data/financial_mock.dart';
import 'package:portal_orbita/features/financial/presentation/financial_screen.dart';
import 'package:portal_orbita/features/financial/presentation/payment_screen.dart';
import 'package:portal_orbita/features/financial/presentation/widgets/decorative_qr_code.dart';

import 'helpers.dart';

Future<void> openFinancial(WidgetTester tester) async {
  await loginAs(tester);
  await openFromMore(tester, 'Financeiro');
}

/// Captura o texto enviado à área de transferência.
String? Function() mockClipboard(WidgetTester tester) {
  String? copied;
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return () => copied;
}

void main() {
  test('fixtures mantêm a fatura de novembro e três pagamentos', () {
    expect(demoInvoice.label, 'MENSALIDADE · NOVEMBRO');
    expect(demoInvoice.dueDate, '10/12/2026');
    expect(demoInvoice.netAmount, r'R$ 1.178,00');
    expect(demoInvoice.barcode, isNotEmpty);
    expect(demoInvoice.pixCode, startsWith('000201'));
    expect(demoPayments.map((payment) => payment.month), [
      'Outubro/2026',
      'Setembro/2026',
      'Agosto/2026',
    ]);
  });

  testWidgets('fatura mostra valores, total e histórico', (tester) async {
    await openFinancial(tester);

    expect(find.text('Fatura em aberto'), findsOneWidget);
    expect(find.text('Vence em 10/12/2026 · faltam 21 dias'), findsOneWidget);
    for (final text in [
      r'R$ 1.240,00',
      r'− R$ 62,00',
      'Total até o vencimento',
      r'R$ 1.178,00',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.text(r'Pago · R$ 1.178,00'), findsNWidgets(3));
  });

  testWidgets('Pagar com Pix mostra QR decorativo e copia o código', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final copied = mockClipboard(tester);
    await openFinancial(tester);
    await tapVisible(tester, find.text('Pagar com Pix'));

    expect(find.byType(PaymentScreen), findsOneWidget);
    expect(find.text('Simulação'), findsOneWidget);
    expect(find.byType(DecorativeQrCode), findsOneWidget);
    expect(find.bySemanticsLabel('QR Code Pix fictício'), findsOneWidget);
    await tapVisible(tester, find.text('Copiar código Pix'));
    expect(copied(), demoInvoice.pixCode);
    expect(find.text('Código Pix copiado!'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('Boleto (2ª via) mostra a linha digitável e copia o código', (
    tester,
  ) async {
    final copied = mockClipboard(tester);
    await openFinancial(tester);
    await tapVisible(tester, find.text('Boleto (2ª via)'));

    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Boleto'))
          .selected,
      isTrue,
    );
    expect(find.byType(DecorativeQrCode), findsNothing);
    expect(find.text(demoInvoice.barcode), findsOneWidget);
    await tapVisible(tester, find.text('Copiar código de barras'));
    expect(copied(), demoInvoice.barcode);
    expect(find.text('Código de barras copiado!'), findsOneWidget);

    await tapVisible(tester, find.text('Baixar PDF da 2ª via'));
    expect(find.textContaining('após integração'), findsOneWidget);
  });

  testWidgets('trocar Pix e Boleto alterna QR e código de barras', (
    tester,
  ) async {
    await pumpScreen(tester, const PaymentScreen());
    expect(find.byType(DecorativeQrCode), findsOneWidget);
    expect(find.byType(DecorativeBarcode), findsNothing);

    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Boleto'));
    expect(find.byType(DecorativeQrCode), findsNothing);
    expect(find.byType(DecorativeBarcode), findsOneWidget);
  });

  testWidgets('barras financeiras são decorativas e repetíveis', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const PaymentScreen(initialMethod: PaymentMethod.boleto),
    );
    final barcode = find.byType(DecorativeBarcode).first;
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

  for (final size in testViewports) {
    testWidgets('fatura e pagamento alcançáveis sem overflow em $size', (
      tester,
    ) async {
      useViewport(tester, size, textScale: 2);
      await pumpScreen(tester, const FinancialScreen());
      await tester.ensureVisible(find.text('Agosto/2026'));
      await tester.pumpAndSettle();
      await pumpScreen(tester, const PaymentScreen());
      await tester.ensureVisible(find.text('Baixar PDF da 2ª via'));
      await tester.pumpAndSettle();
      await pumpScreen(
        tester,
        const PaymentScreen(initialMethod: PaymentMethod.boleto),
      );
      await tester.ensureVisible(find.text('Baixar PDF da 2ª via'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
