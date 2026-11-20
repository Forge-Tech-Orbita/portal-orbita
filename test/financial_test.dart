import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/features/financial/data/financial_mock.dart';
import 'package:portal_orbita/features/financial/presentation/financial_screen.dart';
import 'package:portal_orbita/features/financial/presentation/payment_screen.dart';

import 'helpers.dart';

Future<void> openFinancial(WidgetTester tester) async {
  await loginAs(tester);
  await openFromMore(tester, 'Financeiro');
}

void main() {
  test('fixtures mantêm a fatura de novembro e três pagamentos', () {
    expect(demoInvoice.label, 'MENSALIDADE · NOVEMBRO');
    expect(demoInvoice.dueDate, '10/12/2026');
    expect(demoInvoice.total, r'R$ 1.178,00');
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

  testWidgets('Pagar com Pix abre o pagamento e copia o código', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
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
    await openFinancial(tester);
    await tapVisible(tester, find.text('Pagar com Pix'));

    expect(find.byType(PaymentScreen), findsOneWidget);
    expect(find.text('Simulação'), findsOneWidget);
    expect(find.bySemanticsLabel('QR Code Pix fictício'), findsOneWidget);
    await tapVisible(tester, find.text('Copiar código Pix'));
    expect(copied, demoPixCode);
    expect(find.text('Código Pix copiado (simulação).'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('Boleto abre direto na linha digitável', (tester) async {
    await openFinancial(tester);
    await tapVisible(tester, find.text('Boleto (2ª via)'));

    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Boleto'))
          .selected,
      isTrue,
    );
    expect(find.text('Copiar código Pix'), findsNothing);
    expect(find.text(demoBoletoLine), findsOneWidget);
    await tapVisible(tester, find.text('Baixar PDF da 2ª via'));
    expect(find.textContaining('após integração'), findsOneWidget);
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
      expect(tester.takeException(), isNull);
    });
  }
}
