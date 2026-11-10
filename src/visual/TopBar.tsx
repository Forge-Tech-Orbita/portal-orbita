import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { fontFamily, radius, spacing } from '../constants';
import { Theme, useColors, useThemedStyles } from '../theme';
import { ThemeToggle } from './ThemeToggle';

interface TopBarProps {
  title: string;
  onBack: () => void;
  /**
   * Desliga o atalho de tema no cabeçalho. Usado no Perfil, que já tem a
   * linha "Modo escuro" na lista de preferências — dois controles para a
   * mesma coisa na mesma tela só confundem.
   */
  showThemeToggle?: boolean;
}

/** Cabeçalho com botão de voltar, usado em todas as telas secundárias. */
export function TopBar({ title, onBack, showThemeToggle = true }: TopBarProps) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  return (
    <View style={styles.row}>
      <Pressable
        onPress={onBack}
        style={styles.backBtn}
        hitSlop={8}
        accessibilityRole="button"
        accessibilityLabel="Voltar"
      >
        <Feather name="chevron-left" size={18} color={colors.violet} />
      </Pressable>
      <Text style={styles.title} numberOfLines={1}>
        {title}
      </Text>
      {showThemeToggle && <ThemeToggle />}
    </View>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    row: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.md,
      paddingVertical: spacing.lg - 2,
    },
    backBtn: {
      width: 34,
      height: 34,
      borderRadius: radius.sm + 2,
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: t.colors.panel,
      borderWidth: 1,
      borderColor: t.colors.line,
      ...t.shadow.sm,
    },
    title: {
      flex: 1,
      fontFamily: fontFamily.bodyBold,
      fontSize: 19,
      color: t.colors.text,
    },
  });
