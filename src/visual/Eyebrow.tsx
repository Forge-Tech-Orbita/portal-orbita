import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { fontFamily } from '../constants';
import { Theme, useThemedStyles } from '../theme';

interface EyebrowProps {
  label: string;
  style?: object;
}

/** Rótulo curto em caixa alta, com um traço à esquerda — usado como "olho" de seção. */
export function Eyebrow({ label, style }: EyebrowProps) {
  const styles = useThemedStyles(makeStyles);
  return (
    <View style={[styles.row, style]}>
      <View style={styles.dash} />
      <Text style={styles.label}>{label}</Text>
    </View>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    row: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: 8,
      marginBottom: 6,
    },
    dash: {
      width: 14,
      height: 2,
      borderRadius: 2,
      backgroundColor: t.colors.cyan,
    },
    label: {
      fontFamily: fontFamily.monoBold,
      fontSize: 10.5,
      letterSpacing: 1.5,
      textTransform: 'uppercase',
      color: t.colors.cyan,
    },
  });
