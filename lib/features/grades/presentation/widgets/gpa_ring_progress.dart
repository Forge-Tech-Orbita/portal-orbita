import 'package:flutter/material.dart';

import '../../../../core/theme/orbita_theme.dart';

class GpaRingProgress extends StatelessWidget {
  const GpaRingProgress({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: 'CRA demonstrativo',
      value: '${value.toStringAsFixed(1)} de 10',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: value / 10,
                  strokeWidth: 8,
                  backgroundColor: OrbitaTheme.border,
                  color: OrbitaTheme.primary,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.toStringAsFixed(1),
                    style: textTheme.headlineSmall,
                  ),
                  Text('CRA', style: textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
