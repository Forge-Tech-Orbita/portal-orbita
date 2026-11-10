import React, { useMemo } from 'react';
import { StyleSheet, View } from 'react-native';
import { Theme, useThemedStyles } from '../theme';

interface BarcodeProps {
  bars?: number;
  minHeight?: number;
  maxHeight?: number;
}

/**
 * Ruído determinístico a partir do índice da barra. Substitui `Math.random()`,
 * que é impuro e redesenhava o código de barras a cada remontagem — e, pior,
 * dava um desenho diferente na carteirinha da Home e na do Perfil.
 */
function noiseAt(index: number) {
  const wave = Math.sin((index + 1) * 12.9898) * 43758.5453;
  return wave - Math.floor(wave);
}

/** Código de barras decorativo (carteirinha e boleto), com alturas irregulares. */
export function Barcode({ bars = 14, minHeight = 6, maxHeight = 18 }: BarcodeProps) {
  const styles = useThemedStyles(makeStyles);
  const heights = useMemo(
    () =>
      Array.from({ length: bars }, (_, index) => minHeight + noiseAt(index) * (maxHeight - minHeight)),
    [bars, minHeight, maxHeight],
  );

  return (
    <View style={styles.row}>
      {heights.map((height, index) => (
        <View key={index} style={[styles.bar, { height }]} />
      ))}
    </View>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    row: {
      flexDirection: 'row',
      alignItems: 'flex-end',
      gap: 2,
    },
    bar: {
      width: 2,
      backgroundColor: t.colors.text,
      opacity: 0.65,
    },
  });
