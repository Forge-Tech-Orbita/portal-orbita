import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/theme/orbita_colors.dart';
import 'package:portal_orbita/core/theme/orbita_theme.dart';
import 'package:portal_orbita/core/theme/orbita_theme_controller.dart';
import 'package:portal_orbita/features/navigation/presentation/main_navigation_screen.dart';
import 'package:portal_orbita/features/profile/presentation/profile_screen.dart';

Future<void> openProfile(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  await tester.ensureVisible(find.text('ENTRAR NO PORTAL'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Mais'));
  await tester.pumpAndSettle();
  await tapVisible(tester, find.widgetWithText(OutlinedButton, 'Perfil'));
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder themeTile(String label) => find.widgetWithText(ListTile, label);

ThemeData profileTheme(WidgetTester tester) {
  return Theme.of(tester.element(find.byType(ProfileScreen)));
}

void main() {
  testWidgets('perfil oferece os quatro temas com o vintage selecionado', (
    tester,
  ) async {
    await openProfile(tester);

    expect(find.text('Tema do aplicativo'), findsOneWidget);
    for (final option in OrbitaThemeOption.values) {
      expect(themeTile(option.label), findsOneWidget);
    }
    expect(tester.widget<ListTile>(themeTile('Vintage')).selected, isTrue);
    expect(profileTheme(tester).colorScheme.primary, OrbitaTheme.primary);
    expect(find.byType(ChoiceChip), findsNothing);
  });

  testWidgets('Forge Tech aplica o tema escuro em todo o app', (tester) async {
    await openProfile(tester);

    await tapVisible(tester, themeTile('Forge Tech'));

    final theme = profileTheme(tester);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, OrbitaColors.forgeTech.background);
    expect(theme.colorScheme.primary, OrbitaColors.forgeTech.primary);
    expect(tester.widget<ListTile>(themeTile('Forge Tech')).selected, isTrue);
    expect(tester.widget<ListTile>(themeTile('Vintage')).selected, isFalse);

    // O tema escolhido continua valendo nas abas principais.
    await tester.pageBack();
    await tester.pumpAndSettle();
    final mainTheme = Theme.of(
      tester.element(find.byType(MainNavigationScreen)),
    );
    expect(mainTheme.brightness, Brightness.dark);
    expect(
      mainTheme.scaffoldBackgroundColor,
      OrbitaColors.forgeTech.background,
    );
  });

  testWidgets('UniSapiens usa roxo, laranja e fundo claro', (tester) async {
    await openProfile(tester);

    await tapVisible(tester, themeTile('UniSapiens'));

    final theme = profileTheme(tester);
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, OrbitaColors.uniSapiens.primary);
    expect(theme.colorScheme.secondary, OrbitaColors.uniSapiens.secondary);
    expect(theme.scaffoldBackgroundColor, OrbitaColors.uniSapiens.background);
  });

  testWidgets('tema básico permite escolher a cor de destaque', (tester) async {
    await openProfile(tester);

    await tapVisible(tester, themeTile('Básico'));

    expect(
      find.byType(ChoiceChip),
      findsNWidgets(BasicThemeColor.values.length),
    );
    expect(
      profileTheme(tester).colorScheme.primary,
      BasicThemeColor.blue.color,
    );

    final purple = find.widgetWithText(ChoiceChip, 'Roxo');
    await tapVisible(tester, purple);

    expect(tester.widget<ChoiceChip>(purple).selected, isTrue);
    expect(
      profileTheme(tester).colorScheme.primary,
      BasicThemeColor.purple.color,
    );

    await tapVisible(tester, themeTile('Vintage'));

    expect(profileTheme(tester).colorScheme.primary, OrbitaTheme.primary);
    expect(find.byType(ChoiceChip), findsNothing);
  });

  testWidgets('perfil fora do app não mostra o seletor de tema', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: OrbitaTheme.data, home: const ProfileScreen()),
    );

    expect(find.text('Tema do aplicativo'), findsNothing);
    expect(find.text('Meu perfil'), findsOneWidget);
  });
}
