import 'package:flutter/material.dart';

String greetingForHour(int hour) =>
    hour < 12 ? 'Bom dia' : (hour < 18 ? 'Boa tarde' : 'Boa noite');

/// Cabeçalho das abas: sobretítulo em caixa alta, título e subtítulo.
class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.title,
    this.overline,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? overline;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final overline = this.overline;
    final subtitle = this.subtitle;
    final trailing = this.trailing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overline != null)
                Text(overline.toUpperCase(), style: textTheme.labelMedium),
              Text(title, style: textTheme.headlineSmall),
              if (subtitle != null) Text(subtitle, style: textTheme.bodySmall),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Título de seção com ação textual opcional à direita.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = this.actionLabel;

    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}
