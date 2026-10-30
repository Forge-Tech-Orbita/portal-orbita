import 'package:flutter/material.dart';

import '../../../../core/theme/orbita_theme.dart';

class AcademicStatTile extends StatelessWidget {
  const AcademicStatTile({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      color: OrbitaTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: OrbitaTheme.primary,
              ),
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
