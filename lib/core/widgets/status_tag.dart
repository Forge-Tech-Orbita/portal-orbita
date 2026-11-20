import 'package:flutter/material.dart';

import '../theme/orbita_theme.dart';

enum TagTone {
  success(OrbitaTheme.green),
  info(OrbitaTheme.primary),
  danger(OrbitaTheme.alert),
  warning(OrbitaTheme.amber),
  neutral(OrbitaTheme.muted);

  const TagTone(this.color);

  final Color color;
}

/// Etiqueta curta de status, sempre com texto para não depender só da cor.
class StatusTag extends StatelessWidget {
  const StatusTag({super.key, required this.label, this.tone = TagTone.info});

  final String label;
  final TagTone tone;

  @override
  Widget build(BuildContext context) {
    final foreground = switch (tone) {
      TagTone.warning => const Color(0xFF7A5317),
      TagTone.success => const Color(0xFF3F5A27),
      _ => tone == TagTone.neutral ? OrbitaTheme.text : tone.color,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
