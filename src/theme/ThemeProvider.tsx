import React, { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react';
import { Appearance, useColorScheme } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  ColorScheme,
  Theme,
  ThemePreference,
  darkTheme,
  lightTheme,
  resolveScheme,
} from './palettes';

const STORAGE_KEY = '@portal-orbita/color-scheme';

interface ThemeContextValue {
  theme: Theme;
  /** Modo em vigor, já resolvido — 'system' nunca chega aqui. */
  scheme: ColorScheme;
  /** O que o usuário escolheu, incluindo 'system'. */
  preference: ThemePreference;
  /** `false` enquanto a preferência salva ainda está sendo lida do disco. */
  hydrated: boolean;
  setPreference: (preference: ThemePreference) => void;
  /** Alterna claro/escuro de forma explícita, saindo de 'system' se preciso. */
  toggleScheme: () => void;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

function isPreference(value: string | null): value is ThemePreference {
  return value === 'light' || value === 'dark' || value === 'system';
}

function persist(preference: ThemePreference) {
  // Falha ao gravar não pode derrubar a troca de tema — a sessão atual segue correta.
  AsyncStorage.setItem(STORAGE_KEY, preference).catch(() => undefined);
}

/**
 * Guarda a preferência de aparência e a devolve já resolvida em cores. A
 * escolha é gravada no aparelho, então o app reabre como o usuário deixou.
 */
export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [preference, setPreferenceState] = useState<ThemePreference>('system');
  const [hydrated, setHydrated] = useState(false);
  const systemScheme = useColorScheme();

  useEffect(() => {
    let active = true;
    AsyncStorage.getItem(STORAGE_KEY)
      .then((stored) => {
        if (active && isPreference(stored)) {
          setPreferenceState(stored);
        }
      })
      .catch(() => undefined)
      .finally(() => {
        if (active) setHydrated(true);
      });
    return () => {
      active = false;
    };
  }, []);

  const scheme = resolveScheme(preference, systemScheme);

  /**
   * Alinha a camada nativa à preferência. Sem isto, o que o React Native não
   * pinta — teclado, modais e seletores do sistema — destoaria do app.
   *
   * Depende de `preference`, e não de `scheme`: com 'system' passamos
   * 'unspecified', que devolve o controle ao aparelho. Isso importa porque
   * `setColorScheme` também muda o que `useColorScheme` lê — gravar aqui o
   * valor já resolvido congelaria a leitura do sistema no que nós mesmos
   * escrevemos, e o modo automático deixaria de acompanhar o aparelho.
   */
  useEffect(() => {
    // Ausente no React Native Web, onde não há camada nativa para alinhar.
    Appearance.setColorScheme?.(preference === 'system' ? 'unspecified' : preference);
  }, [preference]);

  const setPreference = useCallback((next: ThemePreference) => {
    setPreferenceState(next);
    persist(next);
  }, []);

  const toggleScheme = useCallback(() => {
    // Sai de 'system' para o oposto do que está valendo agora: o atalho do
    // cabeçalho é uma escolha explícita, não um retorno ao automático.
    const next: ColorScheme = scheme === 'dark' ? 'light' : 'dark';
    setPreferenceState(next);
    persist(next);
  }, [scheme]);

  const value = useMemo<ThemeContextValue>(
    () => ({
      theme: scheme === 'dark' ? darkTheme : lightTheme,
      scheme,
      preference,
      hydrated,
      setPreference,
      toggleScheme,
    }),
    [scheme, preference, hydrated, setPreference, toggleScheme],
  );

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export function useTheme(): ThemeContextValue {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme precisa estar dentro de <ThemeProvider>.');
  }
  return context;
}

/** Atalho para quem só precisa das cores da paleta ativa. */
export function useColors() {
  return useTheme().theme.colors;
}

/**
 * Versão temática de `StyleSheet.create`. Recebe a fábrica de estilos declarada
 * no escopo do módulo e a reexecuta sempre que o tema muda — é isto que faz a
 * folha de estilos deixar de ser um retrato fixo das cores do import.
 *
 * A fábrica é quem chama `StyleSheet.create`, para que o TypeScript preserve a
 * tipagem literal dos estilos (`textTransform: 'uppercase'` e afins).
 */
export function useThemedStyles<T>(makeStyles: (theme: Theme) => T): T {
  const { theme } = useTheme();
  return useMemo(() => makeStyles(theme), [theme, makeStyles]);
}
