import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/theme/orbita_colors.dart';
import 'package:portal_orbita/core/theme/orbita_theme.dart';
import 'package:portal_orbita/core/theme/orbita_theme_controller.dart';

void main() {
  test('tema vintage padrão mantém as cores originais', () {
    final theme = OrbitaTheme.data;

    expect(theme.extension<OrbitaColors>(), same(OrbitaColors.vintage));
    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, OrbitaTheme.background);
    expect(theme.colorScheme.primary, OrbitaTheme.primary);
    expect(theme.colorScheme.secondary, OrbitaTheme.terracotta);
    expect(theme.colorScheme.surface, OrbitaTheme.surface);
  });

  test('cada tema gera um ThemeData com a própria paleta', () {
    final forgeTech = OrbitaTheme.build(OrbitaColors.forgeTech);
    expect(forgeTech.brightness, Brightness.dark);
    expect(forgeTech.scaffoldBackgroundColor, const Color(0xFF0F151A));
    expect(forgeTech.colorScheme.primary, const Color(0xFF0AF0F5));
    expect(forgeTech.colorScheme.onSurface, const Color(0xFFEAF2F3));

    final uniSapiens = OrbitaTheme.build(OrbitaColors.uniSapiens);
    expect(uniSapiens.brightness, Brightness.light);
    expect(uniSapiens.colorScheme.primary, const Color(0xFF5B2A86));
    expect(uniSapiens.colorScheme.secondary, const Color(0xFFC2540A));
    expect(uniSapiens.colorScheme.surface, const Color(0xFFFFFFFF));

    for (final color in BasicThemeColor.values) {
      final basic = OrbitaTheme.build(OrbitaColors.basic(color));
      expect(basic.brightness, Brightness.light);
      expect(basic.colorScheme.primary, color.color);
      expect(basic.colorScheme.surface, const Color(0xFFFFFFFF));
    }
  });

  test('cores vintage das fixtures são traduzidas para o tema ativo', () {
    const forgeTech = OrbitaColors.forgeTech;

    expect(forgeTech.resolve(OrbitaTheme.primary), forgeTech.primary);
    expect(forgeTech.resolve(OrbitaTheme.terracotta), forgeTech.secondary);
    expect(forgeTech.resolve(OrbitaTheme.green), forgeTech.success);
    expect(forgeTech.resolve(OrbitaTheme.amber), forgeTech.warning);
    expect(forgeTech.resolve(OrbitaTheme.alert), forgeTech.alert);
    expect(
      OrbitaColors.vintage.resolve(OrbitaTheme.primary),
      OrbitaTheme.primary,
    );
  });

  test('controlador troca o tema e avisa o app', () {
    final controller = OrbitaThemeController();
    addTearDown(controller.dispose);
    var notifications = 0;
    controller.addListener(() => notifications++);

    expect(controller.option, OrbitaThemeOption.vintage);
    expect(controller.colors, same(OrbitaColors.vintage));

    controller.select(OrbitaThemeOption.vintage);
    expect(notifications, 0);

    controller.select(OrbitaThemeOption.forgeTech);
    expect(controller.colors, same(OrbitaColors.forgeTech));
    expect(controller.themeData.brightness, Brightness.dark);
    expect(notifications, 1);

    controller.selectBasicColor(BasicThemeColor.purple);
    expect(controller.option, OrbitaThemeOption.basic);
    expect(controller.basicColor, BasicThemeColor.purple);
    expect(controller.colors.primary, BasicThemeColor.purple.color);
    expect(notifications, 2);

    // A cor do básico fica guardada mesmo ao trocar de tema.
    controller.select(OrbitaThemeOption.uniSapiens);
    expect(controller.basicColor, BasicThemeColor.purple);
    expect(
      controller.paletteFor(OrbitaThemeOption.basic).primary,
      BasicThemeColor.purple.color,
    );
  });
}
