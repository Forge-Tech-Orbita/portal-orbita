import 'package:flutter/material.dart';

/// Paleta de cores usada pelas telas.
///
/// Cada tema do aplicativo fornece a sua própria paleta por meio desta
/// extensão do [ThemeData]. As telas leem as cores com [OrbitaColors.of]
/// em vez de usar as constantes fixas de [OrbitaTheme].
@immutable
class OrbitaColors extends ThemeExtension<OrbitaColors> {
  const OrbitaColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.border,
    required this.text,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.alert,
  });

  /// Indica se a paleta é clara ou escura.
  final Brightness brightness;

  /// Fundo das telas.
  final Color background;

  /// Fundo de cartões, folhas e campos.
  final Color surface;

  /// Contornos e divisórias.
  final Color border;

  /// Cor principal dos textos.
  final Color text;

  /// Cor de destaque principal (botões, ícones e seleção).
  final Color primary;

  /// Cor de textos e ícones sobre [primary].
  final Color onPrimary;

  /// Cor de destaque secundária (no tema vintage, o terracota).
  final Color secondary;

  /// Situações concluídas ou positivas.
  final Color success;

  /// Avisos e pendências.
  final Color warning;

  /// Erros, atrasos e ações destrutivas.
  final Color alert;

  @override
  OrbitaColors copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? border,
    Color? text,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? success,
    Color? warning,
    Color? alert,
  }) {
    return OrbitaColors(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      text: text ?? this.text,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      alert: alert ?? this.alert,
    );
  }

  @override
  OrbitaColors lerp(covariant OrbitaColors? other, double t) {
    if (other == null) return this;

    return OrbitaColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      alert: Color.lerp(alert, other.alert, t)!,
    );
  }
}
