import { useCallback, useEffect, useMemo } from 'react';
import { StyleSheet, View } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import {
  DarkTheme as NavigationDarkTheme,
  DefaultTheme as NavigationLightTheme,
  NavigationContainer,
} from '@react-navigation/native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { useFonts } from 'expo-font';
import * as SplashScreen from 'expo-splash-screen';
import { fontsToLoad } from './src/constants';
import { ThemeProvider, useTheme } from './src/theme';
import { RootNavigator } from './src/navigation/RootNavigator';

SplashScreen.preventAutoHideAsync().catch(() => undefined);

/**
 * Compositor raiz do app: carrega fontes, monta os providers de tema/navegação/
 * área segura e delega toda a UI ao `RootNavigator`. Nenhuma tela ou regra
 * de negócio vive aqui — apenas a composição.
 */
export default function App() {
  return (
    <ThemeProvider>
      <AppShell />
    </ThemeProvider>
  );
}

/**
 * Parte de dentro do provider — precisa ser um componente separado porque a
 * barra de status e o tema do navegador dependem do modo claro/escuro ativo.
 */
function AppShell() {
  const [fontsLoaded, fontsError] = useFonts(fontsToLoad);
  const { theme, scheme, hydrated } = useTheme();

  // Esperar a preferência salva evita abrir no tema claro e piscar para o
  // escuro um instante depois.
  const ready = (fontsLoaded || fontsError) && hydrated;

  const onLayoutRootView = useCallback(async () => {
    if (ready) {
      await SplashScreen.hideAsync();
    }
  }, [ready]);

  useEffect(() => {
    onLayoutRootView();
  }, [onLayoutRootView]);

  const navigationTheme = useMemo(() => {
    const base = scheme === 'dark' ? NavigationDarkTheme : NavigationLightTheme;
    return {
      ...base,
      colors: {
        ...base.colors,
        background: theme.colors.void,
        card: theme.colors.panel,
        text: theme.colors.text,
        border: theme.colors.line,
        primary: theme.colors.violet,
        notification: theme.colors.rose,
      },
    };
  }, [scheme, theme]);

  if (!ready) {
    return null;
  }

  return (
    <SafeAreaProvider>
      <View style={[styles.root, { backgroundColor: theme.colors.void }]} onLayout={onLayoutRootView}>
        <StatusBar style={scheme === 'dark' ? 'light' : 'dark'} />
        <NavigationContainer theme={navigationTheme}>
          <RootNavigator />
        </NavigationContainer>
      </View>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
  },
});
