import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'orbita_colors.dart';
import 'orbita_theme.dart';

/// Temas que o usuário pode escolher nas preferências do perfil.
enum OrbitaThemeOption {
  vintage('Vintage', 'Padrão retrô do Portal Órbita'),
  basic('Básico', 'Visual neutro com a cor que você escolher'),
  forgeTech('Forge Tech', 'Escuro, com as cores da equipe'),
  uniSapiens('UniSapiens', 'Roxo, laranja e branco da universidade');

  const OrbitaThemeOption(this.label, this.description);

  final String label;
  final String description;
}

/// Guarda o tema escolhido e avisa o app quando ele muda.
///
/// Com [preferences] e [userId], a escolha é lida na criação e gravada a cada
/// troca, separada por usuário, e sobrevive ao reinício do app. Sem um dos
/// dois (sem sessão, ou em testes), fica só em memória.
class OrbitaThemeController extends ChangeNotifier {
  OrbitaThemeController({SharedPreferences? preferences, String? userId})
    : _preferences = userId == null ? null : preferences,
      _optionKey = optionKeyFor(userId),
      _basicColorKey = basicColorKeyFor(userId),
      _option = _readOption(preferences, optionKeyFor(userId)),
      _basicColor = _readBasicColor(preferences, basicColorKeyFor(userId));

  static String optionKeyFor(String? userId) => 'orbita.theme.$userId.option';

  static String basicColorKeyFor(String? userId) =>
      'orbita.theme.$userId.basicColor';

  // Valor ausente ou desconhecido (ex.: tema removido) cai no padrão.
  static OrbitaThemeOption _readOption(
    SharedPreferences? preferences,
    String key,
  ) {
    final name = preferences?.getString(key);
    for (final option in OrbitaThemeOption.values) {
      if (option.name == name) return option;
    }
    return OrbitaThemeOption.vintage;
  }

  static BasicThemeColor _readBasicColor(
    SharedPreferences? preferences,
    String key,
  ) {
    final name = preferences?.getString(key);
    for (final color in BasicThemeColor.values) {
      if (color.name == name) return color;
    }
    return BasicThemeColor.blue;
  }

  final SharedPreferences? _preferences;
  final String _optionKey;
  final String _basicColorKey;
  OrbitaThemeOption _option;
  BasicThemeColor _basicColor;

  OrbitaThemeOption get option => _option;

  /// Cor de destaque do tema básico, mantida mesmo com outro tema ativo.
  BasicThemeColor get basicColor => _basicColor;

  /// Paleta do tema ativo.
  OrbitaColors get colors => paletteFor(_option);

  /// Paleta de um tema, usada também nas prévias do seletor.
  OrbitaColors paletteFor(OrbitaThemeOption option) => switch (option) {
    OrbitaThemeOption.vintage => OrbitaColors.vintage,
    OrbitaThemeOption.basic => OrbitaColors.basic(_basicColor),
    OrbitaThemeOption.forgeTech => OrbitaColors.forgeTech,
    OrbitaThemeOption.uniSapiens => OrbitaColors.uniSapiens,
  };

  /// [ThemeData] do tema ativo, usado pelo `MaterialApp`.
  ThemeData get themeData => OrbitaTheme.build(colors);

  void select(OrbitaThemeOption option) {
    if (option == _option) return;
    _option = option;
    _save();
    notifyListeners();
  }

  /// Escolhe a cor do tema básico e ativa esse tema.
  void selectBasicColor(BasicThemeColor color) {
    if (color == _basicColor && _option == OrbitaThemeOption.basic) return;
    _basicColor = color;
    _option = OrbitaThemeOption.basic;
    _save();
    notifyListeners();
  }

  // Gravação sem await: a UI já foi atualizada e o valor fica em cache local.
  void _save() {
    _preferences?.setString(_optionKey, _option.name);
    _preferences?.setString(_basicColorKey, _basicColor.name);
  }
}

/// Disponibiliza o [OrbitaThemeController] para as telas abaixo dele.
class OrbitaThemeScope extends InheritedNotifier<OrbitaThemeController> {
  const OrbitaThemeScope({
    super.key,
    required OrbitaThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Controlador do tema, ou `null` quando a tela é montada fora do app
  /// (por exemplo, em testes isolados).
  static OrbitaThemeController? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<OrbitaThemeScope>();
    return scope?.notifier;
  }
}
