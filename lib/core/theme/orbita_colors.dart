import 'package:flutter/material.dart';

import 'orbita_theme.dart';

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

  /// Paleta do tema ativo. Sem tema configurado (por exemplo, em um teste
  /// com `MaterialApp` simples), usa o tema vintage.
  static OrbitaColors of(BuildContext context) {
    return Theme.of(context).extension<OrbitaColors>() ?? vintage;
  }

  /// Tema padrão do aplicativo, com a estética retrô original.
  static const vintage = OrbitaColors(
    brightness: Brightness.light,
    background: OrbitaTheme.background,
    surface: OrbitaTheme.surface,
    border: OrbitaTheme.border,
    text: OrbitaTheme.text,
    primary: OrbitaTheme.primary,
    onPrimary: OrbitaTheme.surface,
    secondary: OrbitaTheme.terracotta,
    success: OrbitaTheme.green,
    warning: OrbitaTheme.amber,
    alert: OrbitaTheme.alert,
  );

  /// Tema escuro com as cores da logo da equipe Forge Tech.
  static const forgeTech = OrbitaColors(
    brightness: Brightness.dark,
    background: Color(0xFF0F151A),
    surface: Color(0xFF172229),
    border: Color(0xFF2A3B45),
    text: Color(0xFFEAF2F3),
    primary: Color(0xFF0AF0F5),
    onPrimary: Color(0xFF0F151A),
    secondary: Color(0xFF3CC6CF),
    success: Color(0xFF5FD38D),
    warning: Color(0xFFF2C14E),
    alert: Color(0xFFFF7A6E),
  );

  /// Tema claro com as cores da UniSapiens: roxo, laranja e branco.
  static const uniSapiens = OrbitaColors(
    brightness: Brightness.light,
    background: Color(0xFFFAF7FC),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE3D6EE),
    text: Color(0xFF2A1840),
    primary: Color(0xFF5B2A86),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFC2540A),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFB26A00),
    alert: Color(0xFFC62828),
  );

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
