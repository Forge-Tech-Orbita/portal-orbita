import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { fontFamily, spacing } from '../constants';
import { Theme, useColors, useThemedStyles } from '../theme';
import { Button } from './Button';

interface ErrorStateProps {
  message?: string;
  onRetry: () => void;
}

/** Falha de carregamento com saída: explica e oferece tentar de novo. */
export function ErrorState({ message, onRetry }: ErrorStateProps) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  return (
    <View style={styles.wrap}>
      <Feather name="cloud-off" size={34} color={colors.rose} />
      <Text style={styles.title}>Não foi possível carregar</Text>
      <Text style={styles.message}>{message ?? 'Verifique sua conexão e tente novamente.'}</Text>
      <Button label="Tentar de novo" icon="refresh-cw" variant="ghost" onPress={onRetry} style={styles.button} />
    </View>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    wrap: {
      alignItems: 'center',
      paddingVertical: 52,
      paddingHorizontal: spacing.lg,
      gap: spacing.sm,
    },
    title: {
      fontFamily: fontFamily.bodyBold,
      fontSize: 14.5,
      color: t.colors.text,
      marginTop: spacing.sm,
    },
    message: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 12.5,
      color: t.colors.textDim,
      textAlign: 'center',
      lineHeight: 18,
    },
    button: {
      marginTop: spacing.md,
      alignSelf: 'stretch',
    },
  });
