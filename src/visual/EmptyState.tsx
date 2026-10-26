import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { fontFamily } from '../constants';
import { Theme, useColors, useThemedStyles } from '../theme';

interface EmptyStateProps {
  icon: React.ComponentProps<typeof Feather>['name'];
  message: string;
}

/** Estado vazio genérico (ex.: dia sem aulas no Horário). */
export function EmptyState({ icon, message }: EmptyStateProps) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  return (
    <View style={styles.wrap}>
      <Feather name={icon} size={34} color={colors.textFaint} style={styles.icon} />
      <Text style={styles.message}>{message}</Text>
    </View>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    wrap: {
      alignItems: 'center',
      paddingVertical: 60,
      paddingHorizontal: 10,
    },
    icon: {
      marginBottom: 10,
    },
    message: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 12.5,
      color: t.colors.textFaint,
    },
  });
