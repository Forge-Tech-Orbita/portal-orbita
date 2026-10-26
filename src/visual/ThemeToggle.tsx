import React from 'react';
import { Pressable, StyleSheet, ViewStyle } from 'react-native';
import { Feather } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { radius } from '../constants';
import { Theme, useColors, useTheme, useThemedStyles } from '../theme';

interface ThemeToggleProps {
  style?: ViewStyle;
}

/**
 * Atalho de modo noturno presente no cabeçalho de todas as telas. Mostra o
 * destino do toque, não o estado atual: lua quando o app está claro, sol
 * quando está escuro.
 */
export function ThemeToggle({ style }: ThemeToggleProps) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  const { scheme, toggleScheme } = useTheme();
  const isDark = scheme === 'dark';

  const handlePress = () => {
    Haptics.selectionAsync().catch(() => undefined);
    toggleScheme();
  };

  return (
    <Pressable
      onPress={handlePress}
      hitSlop={8}
      accessibilityRole="switch"
      accessibilityState={{ checked: isDark }}
      accessibilityLabel={isDark ? 'Desativar modo noturno' : 'Ativar modo noturno'}
      style={({ pressed }) => [styles.button, pressed && styles.pressed, style]}
    >
      <Feather name={isDark ? 'sun' : 'moon'} size={17} color={colors.violet} />
    </Pressable>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    button: {
      width: 38,
      height: 38,
      borderRadius: radius.md,
      backgroundColor: t.colors.panel,
      borderWidth: 1,
      borderColor: t.colors.line,
      alignItems: 'center',
      justifyContent: 'center',
    },
    pressed: {
      opacity: 0.75,
    },
  });
