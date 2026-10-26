import React from 'react';
import { Pressable, StyleSheet, Text } from 'react-native';
import { fontFamily, radius, spacing } from '../constants';
import { Theme, useThemedStyles } from '../theme';

interface ChipProps {
  label: string;
  active?: boolean;
  onPress?: () => void;
}

/** Chip/pill selecionável — usado para dias da semana, filtros e categorias. */
export function Chip({ label, active, onPress }: ChipProps) {
  const styles = useThemedStyles(makeStyles);
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ selected: Boolean(active) }}
      onPress={onPress}
      style={({ pressed }) => [
        styles.chip,
        active && styles.chipActive,
        pressed && styles.chipPressed,
      ]}
    >
      <Text style={[styles.label, active && styles.labelActive]}>{label}</Text>
    </Pressable>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    chip: {
      paddingVertical: spacing.sm + 1,
      paddingHorizontal: spacing.lg - 2,
      borderRadius: radius.md - 2,
      backgroundColor: t.colors.panel,
      borderWidth: 1,
      borderColor: t.colors.line,
      ...t.shadow.sm,
    },
    chipActive: {
      backgroundColor: t.colors.text,
      borderColor: t.colors.text,
    },
    chipPressed: {
      opacity: 0.75,
    },
    label: {
      fontFamily: fontFamily.monoBold,
      fontSize: 12,
      color: t.colors.textDim,
    },
    labelActive: {
      color: t.colors.onText,
    },
  });
