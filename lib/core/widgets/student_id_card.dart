import 'package:flutter/material.dart';

import '../models/student.dart';
import '../theme/orbita_colors.dart';
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
    final colors = OrbitaColors.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.border, width: 1.5),
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
                Icon(Icons.memory_outlined, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'ATIVO',
                  style: textTheme.labelSmall?.copyWith(color: colors.alert),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colors.text,
                  foregroundColor: colors.surface,
                  backgroundImage: photo,
                  child: photo == null ? Text(student.initials) : null,
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
