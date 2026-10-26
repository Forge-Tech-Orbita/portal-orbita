import React from 'react';
import { Pressable, StyleSheet, Text } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { fontFamily, radius, spacing } from '../constants';
import { Theme, useColors, useThemedStyles } from '../theme';

interface MoreTileProps {
  icon: React.ComponentProps<typeof Feather>['name'];
  title: string;
  description: string;
  tone?: 'default' | 'rose';
  onPress: () => void;
}

/** Card de navegação da tela "Mais" (grade 2 colunas). */
export function MoreTile({ icon, title, description, tone = 'default', onPress }: MoreTileProps) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  const iconColor = tone === 'rose' ? colors.rose : colors.cyan;
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityLabel={`${title}. ${description}`}
      style={({ pressed }) => [styles.tile, pressed && styles.pressed]}
    >
      <Feather name={icon} size={22} color={iconColor} style={styles.icon} />
      <Text style={styles.title}>{title}</Text>
      <Text style={styles.description}>{description}</Text>
    </Pressable>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    tile: {
      flexBasis: '48%',
      flexGrow: 1,
      backgroundColor: t.colors.panel,
      borderWidth: 1,
      borderColor: t.colors.line,
      borderRadius: radius.xl,
      paddingVertical: spacing.xl - 2,
      paddingHorizontal: spacing.lg - 2,
      ...t.shadow.sm,
    },
    pressed: {
      opacity: 0.85,
    },
    icon: {
      marginBottom: spacing.md,
    },
    title: {
      fontFamily: fontFamily.bodyBold,
      fontSize: 13.5,
      color: t.colors.text,
    },
    description: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 10.5,
      color: t.colors.textDim,
      marginTop: 3,
    },
  });
