import 'package:flutter/material.dart';

import '../theme/orbita_colors.dart';
import '../theme/orbita_theme.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.value,
    required this.label,
    this.valueColor = OrbitaTheme.primary,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = OrbitaColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: colors.resolve(valueColor),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: colors.text),
            ),
          ],
        ),
      ),
    );
  }
}
