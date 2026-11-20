import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/theme/orbita_colors.dart';
import 'package:portal_orbita/core/theme/orbita_theme.dart';

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
}
