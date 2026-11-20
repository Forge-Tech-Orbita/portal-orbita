import 'package:flutter/material.dart';

import '../../../../core/theme/orbita_colors.dart';

class AcademicStatTile extends StatelessWidget {
  const AcademicStatTile({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = OrbitaColors.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(color: colors.primary),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
