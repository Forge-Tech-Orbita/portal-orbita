import 'package:flutter/material.dart';

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
/// shortcut: a escolha fica só em memória; ao reiniciar o app, volta ao
/// vintage. Persistir exigiria um pacote de armazenamento local aprovado.
class OrbitaThemeController extends ChangeNotifier {
  OrbitaThemeController({
    OrbitaThemeOption option = OrbitaThemeOption.vintage,
    BasicThemeColor basicColor = BasicThemeColor.blue,
  }) : _option = option,
       _basicColor = basicColor;

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
    notifyListeners();
  }

  /// Escolhe a cor do tema básico e ativa esse tema.
  void selectBasicColor(BasicThemeColor color) {
    if (color == _basicColor && _option == OrbitaThemeOption.basic) return;
    _basicColor = color;
    _option = OrbitaThemeOption.basic;
    notifyListeners();
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
    final scope =
        context.dependOnInheritedWidgetOfExactType<OrbitaThemeScope>();
    return scope?.notifier;
  }
}
