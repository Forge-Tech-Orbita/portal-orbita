import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { fontFamily, radius, spacing } from '../constants';
import { Theme, useThemedStyles } from '../theme';

interface StatTileProps {
  value: string;
  label: string;
}

/** Bloco de estatística curta (CRA, Frequência, Créditos) na Home. */
export function StatTile({ value, label }: StatTileProps) {
  const styles = useThemedStyles(makeStyles);
  return (
    <View style={styles.tile}>
      <Text style={styles.value}>{value}</Text>
      <Text style={styles.label}>{label}</Text>
    </View>
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
      paddingHorizontal: spacing.sm,
      alignItems: 'center',
      ...t.shadow.sm,
    },
    value: {
      fontFamily: fontFamily.monoBold,
      fontSize: 19,
      color: t.colors.cyan,
    },
    label: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 10,
      color: t.colors.textDim,
      marginTop: 3,
    },
  });
