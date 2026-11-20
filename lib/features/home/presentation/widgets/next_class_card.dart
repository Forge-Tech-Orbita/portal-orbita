import 'package:flutter/material.dart';

typedef HomeNextClass = ({
  String subject,
  String details,
  String when,
  String? startsIn,
});

class NextClassCard extends StatelessWidget {
  const NextClassCard({super.key, required this.nextClass});

  final HomeNextClass nextClass;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final startsIn = nextClass.startsIn;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Próxima aula · calculada pela grade',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nextClass.subject, style: textTheme.titleSmall),
                      Text(nextClass.details, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(nextClass.when, style: textTheme.titleSmall),
                    if (startsIn != null)
                      Text(startsIn, style: textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
