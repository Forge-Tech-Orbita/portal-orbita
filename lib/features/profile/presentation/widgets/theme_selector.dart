import 'package:flutter/material.dart';

import '../../../../core/theme/orbita_colors.dart';
import '../../../../core/theme/orbita_theme_controller.dart';

/// Opções para trocar o tema do aplicativo inteiro.
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OrbitaThemeScope.maybeOf(context);
    // Fora do app (por exemplo, em testes isolados) não há tema para trocar.
    if (controller == null) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final colors = OrbitaColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tema do aplicativo', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          color: colors.surface,
          child: Column(
            children: [
              for (final option in OrbitaThemeOption.values)
                ListTile(
                  leading: _PalettePreview(
                    colors: controller.paletteFor(option),
                  ),
                  title: Text(option.label),
                  subtitle: Text(option.description),
                  selected: option == controller.option,
                  selectedColor: colors.primary,
                  trailing: option == controller.option
                      ? Icon(Icons.check_circle, color: colors.primary)
                      : null,
                  onTap: () => controller.select(option),
                ),
            ],
          ),
        ),
        if (controller.option == OrbitaThemeOption.basic) ...[
          const SizedBox(height: 12),
          Text('Cor do tema básico', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final basicColor in BasicThemeColor.values)
                ChoiceChip(
                  avatar: CircleAvatar(backgroundColor: basicColor.color),
                  label: Text(basicColor.label),
                  selected: basicColor == controller.basicColor,
                  onSelected: (_) => controller.selectBasicColor(basicColor),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Miniatura com o fundo e as cores de destaque de um tema.
class _PalettePreview extends StatelessWidget {
  const _PalettePreview({required this.colors});

  final OrbitaColors colors;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 3,
          children: [
            for (final color in [colors.primary, colors.secondary, colors.text])
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
