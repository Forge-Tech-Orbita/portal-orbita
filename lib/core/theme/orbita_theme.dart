import 'package:flutter/material.dart';

abstract final class OrbitaTheme {
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

  static final data = _build();

  static ThemeData _build() {
    final base = ThemeData(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: primary).copyWith(
        primary: primary,
        onPrimary: surface,
        secondary: terracotta,
        onSecondary: surface,
        tertiary: green,
        onTertiary: surface,
        error: alert,
        onError: surface,
        surface: surface,
        onSurface: text,
        onSurfaceVariant: muted,
        outline: border,
        outlineVariant: border,
      ),
    );
    final textTheme = base.textTheme.apply(bodyColor: text, displayColor: text);
    const stadium = StadiumBorder();
    const buttonText = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);

    return base.copyWith(
      textTheme: textTheme.copyWith(
        headlineSmall: textTheme.headlineSmall?.copyWith(fontSize: 22),
        bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 15),
        bodySmall: textTheme.bodySmall?.copyWith(color: muted),
        labelMedium: textTheme.labelMedium?.copyWith(
          color: muted,
          letterSpacing: 0.6,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: _radius,
          side: BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: surface,
          minimumSize: const Size(48, 48),
          shape: stadium,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(48, 48),
          shape: stadium,
          side: const BorderSide(color: primary),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withValues(alpha: 0.14),
        checkmarkColor: primary,
        side: const BorderSide(color: border),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        labelStyle: const TextStyle(color: text, fontSize: 13),
        showCheckmark: true,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: alert),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: alert, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: muted,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : border,
        ),
        thumbColor: const WidgetStatePropertyAll(surface),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: border,
        linearMinHeight: 4,
      ),
      dividerTheme: const DividerThemeData(color: border, space: 1),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
