import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/orbita_colors.dart';
import '../../../core/widgets/decorative_barcode.dart';
import '../../../core/widgets/info_banner.dart';
import '../data/financial_mock.dart';
import 'widgets/decorative_qr_code.dart';

enum PaymentMethod { pix, boleto }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, this.initialMethod = PaymentMethod.pix});

  final PaymentMethod initialMethod;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PaymentMethod _method = widget.initialMethod;

  Future<void> _copy(String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    _showMessage(message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrbitaColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pagar mensalidade')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const InfoBanner(
                title: 'Simulação',
                message: 'QR e linha digitável fictícios, sem valor bancário.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final (method, label) in const [
                    (PaymentMethod.pix, 'Pix'),
                    (PaymentMethod.boleto, 'Boleto'),
                  ])
                    ChoiceChip(
                      label: Text(label),
                      selected: _method == method,
                      onSelected: (_) => setState(() => _method = method),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_method == PaymentMethod.pix)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Semantics(
                            label: 'QR Code Pix fictício',
                            container: true,
                            image: true,
                            child: const DecorativeQrCode(size: 152),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          demoInvoice.netAmount,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall,
                        ),
                        Text(
                          'Mensalidade de novembro · válido até ${demoInvoice.dueDate}',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () =>
                              _copy(demoInvoice.pixCode, 'Código Pix copiado!'),
                          icon: const Icon(Icons.copy_outlined),
                          label: const Text('Copiar código Pix'),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_method == PaymentMethod.pix) const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'BOLETO · LINHA DIGITÁVEL',
                        style: textTheme.labelMedium,
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        demoInvoice.barcode,
                        style: textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_method == PaymentMethod.boleto) ...[
                        FilledButton.icon(
                          onPressed: () => _copy(
                            demoInvoice.barcode,
                            'Código de barras copiado!',
                          ),
                          icon: const Icon(Icons.copy_outlined),
                          label: const Text('Copiar código de barras'),
                        ),
                        const SizedBox(height: 12),
                        const Center(child: DecorativeBarcode(count: 46)),
                        const SizedBox(height: 6),
                        Text(
                          'Código decorativo · sem valor bancário',
                          style: textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],
                      OutlinedButton.icon(
                        onPressed: () => _showMessage(
                          'PDF da 2ª via disponível após integração com o banco.',
                        ),
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('Baixar PDF da 2ª via'),
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
