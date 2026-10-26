import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { fontFamily } from '../constants';
import { Theme, useThemedStyles } from '../theme';

interface SectionHeaderProps {
  title: string;
  actionLabel?: string;
  onActionPress?: () => void;
}

/** Cabeçalho de seção com título e link de ação opcional (ex.: "ver tudo"). */
export function SectionHeader({ title, actionLabel, onActionPress }: SectionHeaderProps) {
  const styles = useThemedStyles(makeStyles);
  return (
    <View style={styles.row}>
      <Text style={styles.title}>{title}</Text>
      {actionLabel && (
        <Pressable
          onPress={onActionPress}
          hitSlop={8}
          accessibilityRole="button"
          accessibilityLabel={`${actionLabel}: ${title}`}
        >
          <Text style={styles.action}>{actionLabel}</Text>
        </Pressable>
      )}
    </View>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    row: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      marginBottom: 10,
    },
    title: {
      fontFamily: fontFamily.bodyBold,
      fontSize: 15,
      color: t.colors.text,
    },
    action: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 11,
      color: t.colors.violet,
    },
  });
