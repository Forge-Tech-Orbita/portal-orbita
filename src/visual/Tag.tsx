import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { fontFamily } from '../constants';
import { Palette, Theme, useColors, useThemedStyles } from '../theme';
import { NoticeCategory } from '../types';
import { noticeCategoryLabel } from '../data';

function categoryTone(colors: Palette, category: NoticeCategory) {
  switch (category) {
    case 'acad':
      return { bg: colors.cyanSoft, fg: colors.cyan };
    case 'event':
      return { bg: colors.violetSoft, fg: colors.violet };
    case 'fin':
      return { bg: colors.amberSoft, fg: colors.amber };
  }
}

/** Etiqueta colorida de categoria (Acadêmico / Eventos / Financeiro). */
export function Tag({ category }: { category: NoticeCategory }) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  const tone = categoryTone(colors, category);
  return (
    <View style={[styles.tag, { backgroundColor: tone.bg }]}>
      <Text style={[styles.label, { color: tone.fg }]}>{noticeCategoryLabel[category]}</Text>
    </View>
  );
}

const makeStyles = (_t: Theme) =>
  StyleSheet.create({
    tag: {
      paddingVertical: 3,
      paddingHorizontal: 7,
      borderRadius: 6,
    },
    label: {
      fontFamily: fontFamily.monoBold,
      fontSize: 8.5,
      letterSpacing: 0.6,
      textTransform: 'uppercase',
    },
  });
