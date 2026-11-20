import 'package:flutter/material.dart';

import '../theme/orbita_colors.dart';
import '../theme/orbita_theme.dart';

/// Tons das etiquetas. A cor guardada é a do tema vintage; a etiqueta a
/// traduz para o tema ativo.
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
    final colors = OrbitaColors.of(context);
    final color = colors.resolve(tone.color);
    final foreground = switch (tone) {
      TagTone.neutral => colors.text,
      _ when colors.brightness == Brightness.dark => color,
      TagTone.warning => const Color(0xFF7A5317),
      TagTone.success => const Color(0xFF3F5A27),
      _ => color,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
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
