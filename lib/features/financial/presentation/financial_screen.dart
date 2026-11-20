import 'package:flutter/material.dart';

import '../../../core/theme/orbita_colors.dart';
import '../../../core/widgets/decorative_barcode.dart';
import '../data/financial_mock.dart';
import 'widgets/invoice_payment_sheet.dart';

class FinancialScreen extends StatelessWidget {
  const FinancialScreen({super.key});

  void _openPaymentSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const InvoicePaymentSheet(invoice: demoInvoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = OrbitaColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Financeiro')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Dados demonstrativos · sem integração financeira',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_outlined, color: colors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fatura em aberto', style: textTheme.titleSmall),
                          Text('Vencimento em ${demoInvoice.dueDate}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                color: colors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(demoInvoice.label, style: textTheme.labelLarge),
                      const SizedBox(height: 12),
                      for (final (label, value) in [
                        ('Valor', demoInvoice.amount),
                        ('Vencimento', demoInvoice.dueDate),
                        ('Desconto pontualidade', demoInvoice.discount),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 12,
                            runSpacing: 4,
                            children: [Text(label), Text(value)],
                          ),
                        ),
                      const SizedBox(height: 8),
                      const Center(child: DecorativeBarcode(count: 46)),
                      const SizedBox(height: 8),
                      Text(
                        'Código decorativo · sem valor bancário',
                        style: textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => _openPaymentSheet(context),
                        child: const Text('Gerar 2ª via'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Histórico de pagamentos', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                color: colors.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final payment in demoPayments)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              Text(payment.month),
                              Text('Pago · ${payment.amount}'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
