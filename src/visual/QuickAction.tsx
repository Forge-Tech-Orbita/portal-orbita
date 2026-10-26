import React from 'react';
import { Pressable, StyleSheet, Text } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { fontFamily, radius, spacing } from '../constants';
import { Theme, useColors, useThemedStyles } from '../theme';

interface QuickActionProps {
  icon: React.ComponentProps<typeof Feather>['name'];
  label: string;
  onPress: () => void;
}

/** Atalho de ação rápida em grade (Financeiro, Biblioteca, Avisos, Suporte...). */
export function QuickAction({ icon, label, onPress }: QuickActionProps) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      style={({ pressed }) => [styles.tile, pressed && styles.pressed]}
    >
      <Feather name={icon} size={19} color={colors.cyan} style={styles.icon} />
      <Text style={styles.label}>{label}</Text>
    </Pressable>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    tile: {
      flex: 1,
      backgroundColor: t.colors.panel,
      borderWidth: 1,
      borderColor: t.colors.line,
      borderRadius: radius.lg,
      paddingVertical: spacing.md,
      paddingHorizontal: spacing.xs,
      alignItems: 'center',
      ...t.shadow.sm,
    },
    pressed: {
      transform: [{ translateY: 1 }],
    },
    icon: {
      marginBottom: 6,
    },
    label: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 10,
      color: t.colors.textDim,
      textAlign: 'center',
    },
  });
