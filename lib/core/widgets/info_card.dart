import 'package:flutter/material.dart';

import '../theme/orbita_theme.dart';

/// Linha em card com ícone, título, subtítulo e conteúdo final opcional.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor = OrbitaTheme.primary,
    this.trailing,
    this.onTap,
    this.showChevron = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = this.subtitle;
    final trailing = this.trailing;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 22, color: iconColor),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.bodyLarge),
                    if (subtitle != null)
                      Text(subtitle, style: textTheme.bodySmall),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: trailing,
                ),
              ],
              if (showChevron) ...[
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: OrbitaTheme.muted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
