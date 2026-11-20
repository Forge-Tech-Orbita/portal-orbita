import 'package:flutter/material.dart';

import '../models/student.dart';
import '../theme/orbita_theme.dart';
import 'decorative_barcode.dart';

class StudentIdCard extends StatelessWidget {
  const StudentIdCard({
    super.key,
    required this.student,
    this.compact = false,
    this.photo,
  });

  final Student student;
  final bool compact;
  final ImageProvider? photo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'INSTITUTO ÓRBITA',
                    style: textTheme.labelMedium?.copyWith(
                      color: OrbitaTheme.text,
                    ),
                  ),
                ),
                const Icon(
                  Icons.memory_outlined,
                  size: 16,
                  color: OrbitaTheme.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'ATIVO',
                  style: textTheme.labelSmall?.copyWith(
                    color: OrbitaTheme.alert,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: OrbitaTheme.primary.withValues(alpha: 0.08),
                    border: Border.all(color: OrbitaTheme.primary, width: 1.5),
                    image: photo == null
                        ? null
                        : DecorationImage(image: photo!, fit: BoxFit.cover),
                  ),
                  child: photo == null
                      ? Semantics(
                          label: 'Foto de ${student.name} não cadastrada',
                          child: const Icon(
                            Icons.person_outline,
                            color: OrbitaTheme.primary,
                          ),
                        )
                      : null,
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
                        style: textTheme.bodySmall?.copyWith(
                          color: OrbitaTheme.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 20,
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
                  const DecorativeBarcode(),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
