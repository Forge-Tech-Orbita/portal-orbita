import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/orbita_colors.dart';
import '../../../../core/widgets/decorative_barcode.dart';
import '../../data/financial.dart';
import 'decorative_qr_code.dart';

enum PaymentMethod {
  boleto(label: 'Boleto', icon: Icons.receipt_long_outlined),
  pix(label: 'Pix QR Code', icon: Icons.qr_code_2_outlined);

  const PaymentMethod({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class InvoicePaymentSheet extends StatefulWidget {
  const InvoicePaymentSheet({super.key, required this.invoice});

  final Invoice invoice;

  @override
  State<InvoicePaymentSheet> createState() => _InvoicePaymentSheetState();
}

class _InvoicePaymentSheetState extends State<InvoicePaymentSheet> {
  PaymentMethod _selectedMethod = PaymentMethod.boleto;

  void _copyToClipboard(String text, String successMessage) {
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(successMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = OrbitaColors.of(context);
    final invoice = widget.invoice;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('2ª via da fatura', style: textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          'Dados demonstrativos · sem valor bancário',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(invoice.label, style: textTheme.labelMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        const Text('Vencimento'),
                        Text(invoice.dueDate),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        const Text('Valor com desconto pontualidade'),
                        Text(
                          invoice.netAmount,
                          style: textTheme.titleSmall?.copyWith(
                            color: colors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<PaymentMethod>(
                segments: [
                  for (final method in PaymentMethod.values)
                    ButtonSegment(
                      value: method,
                      label: Text(method.label),
                      icon: Icon(method.icon),
                    ),
                ],
                selected: {_selectedMethod},
                onSelectionChanged: (selected) {
                  setState(() => _selectedMethod = selected.first);
                },
              ),
              const SizedBox(height: 20),
              if (_selectedMethod == PaymentMethod.boleto) ...[
                Text('Linha digitável', style: textTheme.labelLarge),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: SelectableText(
                    invoice.barcode,
                    style: textTheme.bodyMedium?.copyWith(
                      letterSpacing: 0.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _copyToClipboard(
                    invoice.barcode,
                    'Código de barras copiado!',
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copiar código de barras'),
                ),
                const SizedBox(height: 16),
                const Center(child: DecorativeBarcode(count: 46)),
                const SizedBox(height: 6),
                Text(
                  'Código decorativo · sem valor bancário',
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pague pelo aplicativo do seu banco ou lotérica até a data de vencimento.',
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const Center(child: DecorativeQrCode(size: 160)),
                const SizedBox(height: 8),
                Text(
                  'QR Code decorativo · sem valor bancário',
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text('Pix Copia e Cola', style: textTheme.labelLarge),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    invoice.pixCode,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () =>
                      _copyToClipboard(invoice.pixCode, 'Código Pix copiado!'),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copiar código Pix'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Abra o app do seu banco, escolha Pix e escaneie o QR Code ou cole o código.',
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
