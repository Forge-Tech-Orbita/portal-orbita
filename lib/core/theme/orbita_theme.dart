import 'package:flutter/material.dart';

import 'orbita_colors.dart';

abstract final class OrbitaTheme {
  // Cores do tema vintage, o padrão do aplicativo.
  static const background = Color(0xFFF6F1E3);
  static const surface = Color(0xFFFBF8EF);
  static const border = Color(0xFFDECBA0);
  static const text = Color(0xFF2B2A22);
  static const primary = Color(0xFF2F6F68);
  static const terracotta = Color(0xFFA6543B);
  static const green = Color(0xFF5B7F3A);
  static const amber = Color(0xFFC98A2E);
  static const alert = Color(0xFFAF3B2E);

  /// Tema vintage, usado quando nenhum outro foi escolhido.
  static final data = build(OrbitaColors.vintage);

  /// Monta o [ThemeData] completo a partir de uma paleta.
  static ThemeData build(OrbitaColors colors) {
    final scheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: colors.brightness,
    );

    return ThemeData(
      brightness: colors.brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: scheme.copyWith(
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.onPrimary,
        tertiary: colors.success,
        onTertiary: colors.onPrimary,
        error: colors.alert,
        onError: colors.onPrimary,
        surface: colors.surface,
        onSurface: colors.text,
        outline: colors.border,
      ),
      extensions: [colors],
    );
  }
}
