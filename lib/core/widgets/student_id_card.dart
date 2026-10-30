import 'package:flutter/material.dart';

import '../models/student.dart';
import '../theme/orbita_theme.dart';

class StudentIdCard extends StatelessWidget {
  const StudentIdCard({super.key, required this.student, this.compact = false});

  final Student student;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      color: OrbitaTheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: OrbitaTheme.border, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('INSTITUTO ÓRBITA', style: textTheme.titleSmall),
                ),
                const Icon(Icons.memory_outlined, color: OrbitaTheme.primary),
                const SizedBox(width: 8),
                Text(
                  'ATIVO',
                  style: textTheme.labelSmall?.copyWith(
                    color: OrbitaTheme.alert,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: OrbitaTheme.text,
                  foregroundColor: OrbitaTheme.surface,
                  child: Text(student.initials),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: textTheme.titleSmall),
                      Text(
                        compact
                            ? student.course
                            : '${student.course} · ${student.period}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Matrícula', style: textTheme.labelSmall),
                      Text(student.registration),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Validade', style: textTheme.labelSmall),
                      Text(student.validUntil),
                    ],
                  ),
                  ExcludeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 2,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // shortcut: barras apenas decorativas, substituir se houver identificação escaneável real.
                        for (final height in const [
                          8.0,
                          18.0,
                          12.0,
                          20.0,
                          10.0,
                          16.0,
                          9.0,
                          19.0,
                          14.0,
                          8.0,
                          17.0,
                          11.0,
                          20.0,
                          13.0,
                        ])
                          SizedBox(
                            width: 2,
                            height: height,
                            child: const ColoredBox(color: OrbitaTheme.text),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
