import 'package:flutter/material.dart';

abstract final class OrbitaTheme {
  static const background = Color(0xFFF6F1E3);
  static const surface = Color(0xFFFBF8EF);
  static const border = Color(0xFFDECBA0);
  static const text = Color(0xFF2B2A22);
  static const primary = Color(0xFF2F6F68);
  static const terracotta = Color(0xFFA6543B);
  static const green = Color(0xFF5B7F3A);
  static const amber = Color(0xFFC98A2E);
  static const alert = Color(0xFFAF3B2E);

  static final data = ThemeData(
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
      outline: border,
    ),
  );
}
