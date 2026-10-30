import 'package:flutter/material.dart';

import '../../../../core/theme/orbita_theme.dart';

class NextClassCard extends StatelessWidget {
  const NextClassCard({
    super.key,
    required this.subject,
    required this.details,
    required this.time,
    required this.startsIn,
  });

  final String subject;
  final String details;
  final String time;
  final String startsIn;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      color: OrbitaTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Próxima aula · demonstração', style: textTheme.labelSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subject, style: textTheme.titleSmall),
                      Text(details, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(startsIn),
                      Text(time, style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
