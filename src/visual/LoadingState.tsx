import React from 'react';
import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';
import { fontFamily } from '../constants';
import { Theme, useColors, useThemedStyles } from '../theme';

interface LoadingStateProps {
  message?: string;
}

/** Espera padrão enquanto o portal responde. */
export function LoadingState({ message = 'Carregando...' }: LoadingStateProps) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  return (
    <View style={styles.wrap} accessibilityRole="progressbar" accessibilityLabel={message}>
      <ActivityIndicator color={colors.cyan} />
      <Text style={styles.message}>{message}</Text>
    </View>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    wrap: {
      alignItems: 'center',
      paddingVertical: 60,
      gap: 12,
    },
    message: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 12,
      color: t.colors.textFaint,
      letterSpacing: 0.5,
    },
  });
