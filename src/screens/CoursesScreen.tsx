import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { fontFamily, spacing } from '../constants';
import { Theme, useColors, useThemedStyles } from '../theme';
import { getCourses } from '../services';
import { useResource } from '../hooks/useResource';
import {
  ErrorState,
  Eyebrow,
  LoadingState,
  ProgressBar,
  ScreenContainer,
  ThemeToggle,
} from '../visual';

/** Lista de disciplinas do semestre corrente com progresso individual. */
export function CoursesScreen() {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  const { data, loading, refreshing, error, reload } = useResource(getCourses);

  return (
    <ScreenContainer onRefresh={() => reload({ silent: true })} refreshing={refreshing}>
      <Eyebrow label="Semestre 2026.2" style={styles.eyebrow} />
      <View style={styles.headingRow}>
        <Text style={styles.heading}>Minhas disciplinas</Text>
        <ThemeToggle />
      </View>

      {loading && <LoadingState />}
      {!loading && error && <ErrorState message={error.message} onRetry={() => reload()} />}

      {!loading && !error && data?.map((course) => (
        <View key={course.subject} style={styles.card}>
          <View style={styles.top}>
            <View style={styles.topInfo}>
              <Text style={styles.subject}>{course.subject}</Text>
              <Text style={styles.professor}>{course.professor}</Text>
            </View>
            <View style={styles.creditsBadge}>
              <Text style={styles.creditsLabel}>{course.credits} créditos</Text>
            </View>
          </View>
          <ProgressBar percent={course.progress} color={colors.violet} height={6} />
          <View style={styles.footer}>
            <Text style={styles.footerText}>{course.progress}% do semestre</Text>
            <Text style={styles.footerText}>{course.room}</Text>
          </View>
        </View>
      ))}
    </ScreenContainer>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    eyebrow: {
      marginTop: 16,
    },
    headingRow: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      marginBottom: spacing.xl - 2,
    },
    heading: {
      flex: 1,
      fontFamily: fontFamily.bodyBold,
      fontSize: 19,
      color: t.colors.text,
    },
    card: {
      backgroundColor: t.colors.panel,
      borderWidth: 1,
      borderColor: t.colors.line,
      borderRadius: 16,
      padding: 15,
      marginBottom: spacing.md,
    },
    top: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'flex-start',
      marginBottom: spacing.md - 2,
    },
    topInfo: {
      flex: 1,
      paddingRight: spacing.sm,
    },
    subject: {
      fontFamily: fontFamily.bodyBold,
      fontSize: 14,
      color: t.colors.text,
    },
    professor: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 11.5,
      color: t.colors.textDim,
      marginTop: 3,
    },
    creditsBadge: {
      backgroundColor: t.colors.cyanSoft,
      paddingVertical: 4,
      paddingHorizontal: 8,
      borderRadius: 7,
    },
    creditsLabel: {
      fontFamily: fontFamily.monoBold,
      fontSize: 10,
      color: t.colors.cyan,
    },
    footer: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      marginTop: spacing.sm,
    },
    footerText: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 10.5,
      color: t.colors.textFaint,
    },
  });
