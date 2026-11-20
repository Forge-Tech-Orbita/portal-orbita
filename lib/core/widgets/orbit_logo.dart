import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/orbita_theme.dart';

/// Marca orbital do Instituto Órbita com nome e lema.
class OrbitLogo extends StatelessWidget {
  const OrbitLogo({super.key, this.tagline = 'ENSINO EM OUTRA ÓRBITA'});

  final String tagline;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Semantics(
          label: 'Símbolo orbital do Instituto Órbita',
          image: true,
          child: const CustomPaint(
            size: Size.square(64),
            painter: _OrbitMarkPainter(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'ÓRBITA',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(letterSpacing: 1),
        ),
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: textTheme.labelMedium?.copyWith(color: OrbitaTheme.text),
        ),
      ],
    );
  }
}

class _OrbitMarkPainter extends CustomPainter {
  const _OrbitMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    final paint = Paint()..color = OrbitaTheme.surface;
    canvas.drawCircle(Offset.zero, 30, paint);
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = OrbitaTheme.border;
    canvas.drawCircle(Offset.zero, 30, paint);

    for (final (angle, color) in [
      (0.0, OrbitaTheme.text),
      (math.pi / 3, OrbitaTheme.terracotta),
      (2 * math.pi / 3, OrbitaTheme.amber),
    ]) {
      canvas.save();
      canvas.rotate(angle);
      paint.color = color;
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 42, height: 18),
        paint,
      );
      canvas.restore();
    }

    paint
      ..style = PaintingStyle.fill
      ..color = OrbitaTheme.text;
    canvas.drawCircle(Offset.zero, 5.5, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitMarkPainter oldDelegate) => false;
}
