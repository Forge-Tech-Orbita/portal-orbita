import React, { useMemo, useState } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { fontFamily, spacing } from '../constants';
import { Theme, useColors, useThemedStyles } from '../theme';
import { dayKeyForDate, dayNames, dayOrder } from '../data';
import { getSchedule } from '../services';
import { useResource } from '../hooks/useResource';
import { DayKey } from '../types';
import {
  Chip,
  EmptyState,
  ErrorState,
  Eyebrow,
  LoadingState,
  ScreenContainer,
  ThemeToggle,
} from '../visual';

/**
 * Dia aberto ao entrar na tela. No domingo não existe grade, então a tela
 * começa na segunda — o próximo dia com aula — em vez de num sábado vazio.
 */
function resolveInitialDay(): DayKey {
  return dayKeyForDate(new Date()) ?? 'SEG';
}

/** Grade semanal de aulas com seletor de dia — equivalente às telas "Horário". */
export function ScheduleScreen() {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  const [selectedDay, setSelectedDay] = useState<DayKey>(resolveInitialDay);
  const { data, loading, error, reload } = useResource(getSchedule);

  const classes = useMemo(() => data?.[selectedDay] ?? [], [data, selectedDay]);

  return (
    <ScreenContainer scrollable={false}>
      <Eyebrow label="Horário semanal" style={styles.eyebrow} />
      <View style={styles.headingRow}>
        <Text style={styles.heading}>Suas aulas</Text>
        <ThemeToggle />
      </View>

      {loading && <LoadingState />}
      {!loading && error && <ErrorState message={error.message} onRetry={() => reload()} />}

      {!loading && !error && data && (
        <>
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.dayChips}
          >
            {dayOrder.map((day) => (
              <Chip
                key={day}
                label={day}
                active={day === selectedDay}
                onPress={() => setSelectedDay(day)}
              />
            ))}
          </ScrollView>

          <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.list}>
            {classes.length === 0 ? (
              <EmptyState icon="calendar" message={`Sem aulas em ${dayNames[selectedDay]}`} />
            ) : (
              classes.map((session, index) => (
                <View key={`${session.time}-${session.subject}`} style={styles.classItem}>
                  <Text style={styles.time}>{session.time}</Text>
                  <View style={styles.timeline}>
                    <View style={[styles.node, { backgroundColor: colors[session.accent] }]} />
                    {index < classes.length - 1 && <View style={styles.stem} />}
                  </View>
                  <View style={styles.classCard}>
                    <Text style={styles.subject}>{session.subject}</Text>
                    <View style={styles.metaRow}>
                      <Text style={styles.meta}>{session.room}</Text>
                      <Text style={styles.meta}>{session.professor}</Text>
                    </View>
                  </View>
                </View>
              ))
            )}
          </ScrollView>
        </>
      )}
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
      marginBottom: spacing.lg,
    },
    heading: {
      flex: 1,
      fontFamily: fontFamily.bodyBold,
      fontSize: 19,
      color: t.colors.text,
    },
    dayChips: {
      gap: spacing.sm,
      paddingBottom: spacing.md + 2,
    },
    list: {
      paddingBottom: spacing.xxl,
    },
    classItem: {
      flexDirection: 'row',
      gap: spacing.md,
      marginBottom: spacing.md,
    },
    time: {
      width: 44,
      textAlign: 'right',
      paddingTop: 14,
      fontFamily: fontFamily.monoBold,
      fontSize: 11,
      color: t.colors.textDim,
    },
    timeline: {
      alignItems: 'center',
    },
    node: {
      width: 10,
      height: 10,
      borderRadius: 5,
      marginTop: 12,
      borderWidth: 2,
      borderColor: t.colors.panel,
    },
    stem: {
      flex: 1,
      width: 1,
      backgroundColor: t.colors.line,
      marginVertical: 4,
    },
    classCard: {
      flex: 1,
      backgroundColor: t.colors.panel,
      borderWidth: 1,
      borderColor: t.colors.line,
      borderRadius: 14,
      paddingVertical: spacing.md,
      paddingHorizontal: spacing.lg - 2,
      marginBottom: 2,
    },
    subject: {
      fontFamily: fontFamily.bodyBold,
      fontSize: 13.5,
      color: t.colors.text,
    },
    metaRow: {
      flexDirection: 'row',
      flexWrap: 'wrap',
      gap: spacing.md - 2,
      marginTop: 4,
    },
    meta: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 11,
      color: t.colors.textDim,
    },
  });
