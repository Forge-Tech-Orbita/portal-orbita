import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/info_banner.dart';
import '../data/financial_mock.dart';
import 'payment_screen.dart';

class FinancialScreen extends StatelessWidget {
  const FinancialScreen({super.key});

  void _openPayment(BuildContext context, PaymentMethod method) {
    Navigator.of(context).pushNamed(AppRoutes.payment, arguments: method);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Financeiro')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Dados demonstrativos · pagamento simulado',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              InfoBanner(
                title: 'Fatura em aberto',
                message:
                    'Vence em ${demoInvoice.dueDate} · faltam ${demoInvoice.daysLeft} dias',
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(demoInvoice.label, style: textTheme.labelMedium),
                      const SizedBox(height: 10),
                      for (final (label, value) in [
                        ('Valor', demoInvoice.amount),
                        ('Vencimento', demoInvoice.dueDate),
                        ('Desconto pontualidade', demoInvoice.discount),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AmountRow(label: label, value: value),
                        ),
                      const Divider(height: 8),
                      const SizedBox(height: 8),
                      _AmountRow(
                        label: 'Total até o vencimento',
                        value: demoInvoice.total,
                        bold: true,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _openPayment(context, PaymentMethod.boleto),
                              icon: const Icon(Icons.receipt_long_outlined),
                              label: const Text('Boleto (2ª via)'),
                            ),
                          ),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () =>
                                  _openPayment(context, PaymentMethod.pix),
                              icon: const Icon(Icons.qr_code_2),
                              label: const Text('Pagar com Pix'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Histórico de pagamentos', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final payment in demoPayments)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _AmountRow(
                            label: payment.month,
                            value: 'Pago · ${payment.amount}',
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

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold ? Theme.of(context).textTheme.titleSmall : null;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 12,
      runSpacing: 4,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
