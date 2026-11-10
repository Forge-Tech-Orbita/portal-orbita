import React from 'react';
import { StyleSheet, View } from 'react-native';
import { Theme, useColors, useThemedStyles } from '../theme';

interface ProgressBarProps {
  /** 0 a 100 */
  percent: number;
  color?: string;
  height?: number;
}

/** Barra de progresso simples (usada em disciplinas e no detalhe de notas). */
export function ProgressBar({ percent, color, height = 6 }: ProgressBarProps) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  const fillColor = color ?? colors.violet;
  const clamped = Math.max(0, Math.min(100, percent));
  return (
    <View style={[styles.track, { height, borderRadius: height / 2 }]}>
      <View
        style={[
          styles.fill,
          { width: `${clamped}%`, backgroundColor: fillColor, borderRadius: height / 2 },
        ]}
      />
    </View>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    track: {
      backgroundColor: t.colors.panel3,
      overflow: 'hidden',
    },
    fill: {
      height: '100%',
    },
  });
