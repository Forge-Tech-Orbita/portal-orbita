import React from 'react';
import { StyleSheet, View, ViewProps } from 'react-native';
import { radius, spacing } from '../constants';
import { Theme, useThemedStyles } from '../theme';

/** Painel "de papel" — base de praticamente todo bloco de conteúdo do app. */
export function Card({ style, children, ...rest }: ViewProps) {
  const styles = useThemedStyles(makeStyles);
  return (
    <View style={[styles.card, style]} {...rest}>
      {children}
    </View>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    card: {
      backgroundColor: t.colors.panel,
      borderWidth: 1,
      borderColor: t.colors.line,
      borderRadius: radius.xl,
      padding: spacing.lg,
      ...t.shadow.md,
    },
  });
