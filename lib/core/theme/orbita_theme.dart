import 'package:flutter/material.dart';

import 'orbita_colors.dart';

abstract final class OrbitaTheme {
  // Cores do tema vintage, o padrão do aplicativo.
  static const background = Color(0xFFF6F1E3);
  static const surface = Color(0xFFFBF8EF);
  static const border = Color(0xFFE3D8BF);
  static const text = Color(0xFF2B2A22);
  static const muted = Color(0xFF6E6A5C);
  static const primary = Color(0xFF2F6F68);
  static const terracotta = Color(0xFFA6543B);
  static const green = Color(0xFF5B7F3A);
  static const amber = Color(0xFFC98A2E);
  static const alert = Color(0xFFAF3B2E);

  static const _radius = BorderRadius.all(Radius.circular(12));
  static const _fieldRadius = BorderRadius.all(Radius.circular(10));

  /// Tema vintage, usado quando nenhum outro foi escolhido.
  static final data = build(OrbitaColors.vintage);

  /// Monta o [ThemeData] completo, com os componentes do protótipo, a partir
  /// de uma paleta.
  static ThemeData build(OrbitaColors colors) {
    final scheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: colors.brightness,
    );
    final base = ThemeData(
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
        onSurfaceVariant: colors.muted,
        outline: colors.border,
        outlineVariant: colors.border,
      ),
      extensions: [colors],
    );
    final textTheme = base.textTheme.apply(
      bodyColor: colors.text,
      displayColor: colors.text,
    );
    const stadium = StadiumBorder();
    const buttonText = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);

    return base.copyWith(
      textTheme: textTheme.copyWith(
        headlineSmall: textTheme.headlineSmall?.copyWith(fontSize: 22),
        bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 15),
        bodySmall: textTheme.bodySmall?.copyWith(color: colors.muted),
        labelMedium: textTheme.labelMedium?.copyWith(
          color: colors.muted,
          letterSpacing: 0.6,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colors.text,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: _radius,
          side: BorderSide(color: colors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size(48, 48),
          shape: stadium,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(48, 48),
          shape: stadium,
          side: BorderSide(color: colors.primary),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.primary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        selectedColor: colors.primary.withValues(alpha: 0.14),
        checkmarkColor: colors.primary,
        side: BorderSide(color: colors.border),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        labelStyle: TextStyle(color: colors.text, fontSize: 13),
        showCheckmark: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: colors.alert),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: colors.alert, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.muted,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.border,
        ),
        thumbColor: WidgetStatePropertyAll(colors.surface),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.border,
        linearMinHeight: 4,
      ),
      dividerTheme: DividerThemeData(color: colors.border, space: 1),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
