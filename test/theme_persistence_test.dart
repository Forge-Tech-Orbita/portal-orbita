import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/theme/orbita_colors.dart';
import 'package:portal_orbita/core/theme/orbita_theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('sem preferência salva, começa no vintage com azul', () async {
    final controller = OrbitaThemeController(
      preferences: await prefsWith({}),
      userId: 'u1',
    );
    addTearDown(controller.dispose);

    expect(controller.option, OrbitaThemeOption.vintage);
    expect(controller.basicColor, BasicThemeColor.blue);
  });

  test('tema e cor escolhidos sobrevivem a um novo controlador', () async {
    final prefs = await prefsWith({});
    final first = OrbitaThemeController(preferences: prefs, userId: 'u1');
    addTearDown(first.dispose);

    first.select(OrbitaThemeOption.forgeTech);
    first.selectBasicColor(BasicThemeColor.purple);
    first.select(OrbitaThemeOption.uniSapiens);

    final second = OrbitaThemeController(preferences: prefs, userId: 'u1');
    addTearDown(second.dispose);
    expect(second.option, OrbitaThemeOption.uniSapiens);
    expect(second.basicColor, BasicThemeColor.purple);
  });

  test('valores salvos desconhecidos voltam ao padrão', () async {
    final controller = OrbitaThemeController(
      userId: 'u1',
      preferences: await prefsWith({
        OrbitaThemeController.optionKeyFor('u1'): 'removido',
        OrbitaThemeController.basicColorKeyFor('u1'): 'inexistente',
      }),
    );
    addTearDown(controller.dispose);

    expect(controller.option, OrbitaThemeOption.vintage);
    expect(controller.basicColor, BasicThemeColor.blue);
  });

  test('cada usuário tem o próprio tema e sem usuário não persiste', () async {
    final prefs = await prefsWith({});
    final alice = OrbitaThemeController(preferences: prefs, userId: 'a');
    addTearDown(alice.dispose);
    alice.select(OrbitaThemeOption.forgeTech);

    final bob = OrbitaThemeController(preferences: prefs, userId: 'b');
    addTearDown(bob.dispose);
    expect(bob.option, OrbitaThemeOption.vintage);

    final anonymous = OrbitaThemeController(preferences: prefs);
    addTearDown(anonymous.dispose);
    anonymous.select(OrbitaThemeOption.uniSapiens);
    expect(prefs.getKeys(), {
      OrbitaThemeController.optionKeyFor('a'),
      OrbitaThemeController.basicColorKeyFor('a'),
    });
  });
}
