import 'package:flutter/material.dart';

import '../../../../core/theme/orbita_theme.dart';

/// QR code decorativo para telas e faturas demonstrativas, sem leitura bancária real.
class DecorativeQrCode extends StatelessWidget {
  const DecorativeQrCode({super.key, this.size = 160});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: OrbitaTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CustomPaint(
          size: Size(size - 20, size - 20),
          painter: const _QrCodePainter(),
        ),
      ),
    );
  }
}

class _QrCodePainter extends CustomPainter {
  const _QrCodePainter();

  static const int _gridSize = 21;

  static const List<int> _matrixBits = [
    0x1F87F, // 111111100000001111111
    0x10841, // 100000100000001000001
    0x1785D, // 101110100000001011101
    0x1785D, // 101110100000001011101
    0x1785D, // 101110100000001011101
    0x10841, // 100000100000001000001
    0x1F87F, // 111111100000001111111
    0x00000, // 000000000000000000000
    0x15555, // 101010101010101010101
    0x0A92A, // 010101001001001010100
    0x14C65, // 101001100011001100101
    0x0E3B8, // 011100011101110111000
    0x18F43, // 110001111010001000011
    0x00000, // 000000000000000000000
    0x1F800, // 111111100000000000000
    0x108AA, // 100000100000001010101
    0x17855, // 101110100000000101010
    0x1789B, // 101110100000011001101
    0x17870, // 101110100000001110000
    0x1082A, // 100000100000000101010
    0x1F85F, // 111111100000001011111
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / _gridSize;
    final cellHeight = size.height / _gridSize;
    final paint = Paint()
      ..color = OrbitaTheme.text
      ..style = PaintingStyle.fill;

    for (var row = 0; row < _gridSize; row++) {
      final rowBits = _matrixBits[row];
      for (var col = 0; col < _gridSize; col++) {
        if ((rowBits & (1 << (20 - col))) != 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellWidth,
              row * cellHeight,
              cellWidth,
              cellHeight,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
