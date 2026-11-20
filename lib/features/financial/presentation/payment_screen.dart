import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/info_banner.dart';
import '../data/financial_mock.dart';

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
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: OrbitaTheme.border),
                              ),
                              child: const CustomPaint(
                                size: Size.square(132),
                                painter: _FakeQrPainter(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          demoInvoice.total,
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
                          onPressed: () => _copy(
                            demoPixCode,
                            'Código Pix copiado (simulação).',
                          ),
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
                        demoBoletoLine,
                        style: textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: OrbitaTheme.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_method == PaymentMethod.boleto) ...[
                        FilledButton.icon(
                          onPressed: () => _copy(
                            demoBoletoLine,
                            'Linha digitável copiada (simulação).',
                          ),
                          icon: const Icon(Icons.copy_outlined),
                          label: const Text('Copiar linha digitável'),
                        ),
                        const SizedBox(height: 8),
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

/// Padrão determinístico com aparência de QR, sem dados codificados.
class _FakeQrPainter extends CustomPainter {
  const _FakeQrPainter();

  static const _cells = 21;

  bool _isFinder(int row, int col) {
    bool inSquare(int r, int c) => r >= 0 && r < 7 && c >= 0 && c < 7;
    for (final (r0, c0) in const [(0, 0), (0, 14), (14, 0)]) {
      final r = row - r0;
      final c = col - c0;
      if (inSquare(r, c)) {
        final ring = r == 0 || r == 6 || c == 0 || c == 6;
        final core = r >= 2 && r <= 4 && c >= 2 && c <= 4;
        return ring || core;
      }
    }
    return false;
  }

  bool _inFinderArea(int row, int col) =>
      (row < 8 && col < 8) || (row < 8 && col > 12) || (row > 12 && col < 8);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _cells;
    final paint = Paint()..color = OrbitaTheme.text;
    for (var row = 0; row < _cells; row++) {
      for (var col = 0; col < _cells; col++) {
        final filled = _inFinderArea(row, col)
            ? _isFinder(row, col)
            : (row * 7 + col * 13 + row * col) % 3 == 0;
        if (filled) {
          canvas.drawRect(
            Rect.fromLTWH(col * cell, row * cell, cell, cell),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FakeQrPainter oldDelegate) => false;
}
