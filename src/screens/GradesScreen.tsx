import React, { useMemo, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { fontFamily, spacing } from '../constants';
import { Palette, Theme, useColors, useThemedStyles } from '../theme';
import { getGrades } from '../services';
import { useResource } from '../hooks/useResource';
import { Grade } from '../types';
import {
  Chip,
  ErrorState,
  Eyebrow,
  GpaRing,
  LoadingState,
  ProgressBar,
  ScreenContainer,
  ThemeToggle,
} from '../visual';

type GradeFilter = 'todas' | Grade['status'];

const filters: { key: GradeFilter; label: string }[] = [
  { key: 'todas', label: 'Todas' },
  { key: 'cursando', label: 'Cursando' },
  { key: 'concluidas', label: 'Concluídas' },
];

function average(grade: Grade) {
  return grade.av2 != null ? (grade.av1 + grade.av2) / 2 : null;
}

/** Cor e rótulo da pill de média: neutra enquanto cursa, verde/âmbar quando fechada. */
function mediaTone(colors: Palette, media: number | null) {
  if (media === null) {
    return { label: 'Cursando', fg: colors.violet, bg: colors.violetSoft };
  }
  const approved = media >= 7;
  return {
    label: media.toFixed(1),
    fg: approved ? colors.mint : colors.amber,
    bg: approved ? colors.mintSoft : colors.amberSoft,
  };
}

/** Notas e frequência: anel de CRA, filtros e cartões expansíveis por disciplina. */
export function GradesScreen() {
  const styles = useThemedStyles(makeStyles);
  const [filter, setFilter] = useState<GradeFilter>('todas');
  const { data, loading, refreshing, error, reload } = useResource(getGrades);

  const filtered = useMemo(
    () => (data?.grades ?? []).filter((grade) => filter === 'todas' || grade.status === filter),
    [data, filter],
  );

  return (
    <ScreenContainer onRefresh={() => reload({ silent: true })} refreshing={refreshing}>
      <Eyebrow label="Desempenho acadêmico" style={styles.eyebrow} />
      <View style={styles.headingRow}>
        <Text style={styles.heading}>Notas &amp; frequência</Text>
        <ThemeToggle />
      </View>

      {loading && <LoadingState />}
      {!loading && error && <ErrorState message={error.message} onRetry={() => reload()} />}

      {!loading && !error && data && (
        <>
          <View style={styles.summaryRow}>
            <GpaRing value={data.summary.cra} />
            <View style={styles.legend}>
              <View style={styles.legendRow}>
                <Text style={styles.legendLabel}>Aprovadas</Text>
                <Text style={styles.legendValue}>{data.summary.approved}</Text>
              </View>
              <View style={styles.legendRow}>
                <Text style={styles.legendLabel}>Cursando</Text>
                <Text style={styles.legendValue}>{data.summary.inProgress}</Text>
              </View>
              <View style={styles.legendRow}>
                <Text style={styles.legendLabel}>Pendentes</Text>
                <Text style={styles.legendValue}>{data.summary.pending}</Text>
              </View>
            </View>
          </View>

          <View style={styles.filterRow}>
            {filters.map((item) => (
              <Chip
                key={item.key}
                label={item.label}
                active={filter === item.key}
                onPress={() => setFilter(item.key)}
              />
            ))}
          </View>

          {filtered.map((grade) => (
            <GradeCard key={grade.code} grade={grade} />
          ))}
        </>
      )}
    </ScreenContainer>
  );
}

function GradeCard({ grade }: { grade: Grade }) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  const [open, setOpen] = useState(false);
  const tone = mediaTone(colors, average(grade));

  return (
    <Pressable
      style={styles.card}
      onPress={() => setOpen((prev) => !prev)}
      accessibilityRole="button"
      accessibilityState={{ expanded: open }}
      accessibilityLabel={`${grade.subject}, ${open ? 'recolher' : 'expandir'} detalhes`}
    >
      <View style={styles.cardHeader}>
        <View>
          <Text style={styles.subject}>{grade.subject}</Text>
          <Text style={styles.code}>{grade.code}</Text>
        </View>
        <View style={[styles.pill, { backgroundColor: tone.bg }]}>
          <Text style={[styles.pillLabel, { color: tone.fg }]}>{tone.label}</Text>
        </View>
      </View>

      {open && (
        <View style={styles.detail}>
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>AV1</Text>
            <View style={styles.barWrap}>
              <ProgressBar percent={(grade.av1 / 10) * 100} color={colors.cyan} height={5} />
            </View>
            <Text style={styles.detailValue}>{grade.av1.toFixed(1)}</Text>
          </View>
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>AV2</Text>
            <View style={styles.barWrap}>
              <ProgressBar
                percent={grade.av2 != null ? (grade.av2 / 10) * 100 : 0}
                color={colors.cyan}
                height={5}
              />
            </View>
            <Text style={styles.detailValue}>{grade.av2 != null ? grade.av2.toFixed(1) : '—'}</Text>
          </View>
          <Text style={styles.freqNote}>
            Frequência: {grade.frequency}% · Situação:{' '}
            {grade.status === 'cursando' ? 'Em andamento' : 'Aprovado'}
          </Text>
        </View>
      )}
    </Pressable>
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
    summaryRow: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.lg + 2,
      marginBottom: spacing.xl + 2,
    },
    legend: {
      flex: 1,
    },
    legendRow: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      paddingVertical: 4,
    },
    legendLabel: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 12,
      color: t.colors.textDim,
    },
    legendValue: {
      fontFamily: fontFamily.monoBold,
      fontSize: 12,
      color: t.colors.text,
    },
    filterRow: {
      flexDirection: 'row',
      gap: spacing.sm,
      marginBottom: spacing.lg,
    },
    card: {
      backgroundColor: t.colors.panel,
      borderWidth: 1,
      borderColor: t.colors.line,
      borderRadius: 16,
      marginBottom: spacing.md,
      overflow: 'hidden',
    },
    cardHeader: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      paddingVertical: 14,
      paddingHorizontal: spacing.lg,
    },
    subject: {
      fontFamily: fontFamily.bodyBold,
      fontSize: 13.5,
      color: t.colors.text,
    },
    code: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 10.5,
      color: t.colors.textFaint,
      marginTop: 2,
    },
    pill: {
      paddingVertical: 5,
      paddingHorizontal: 10,
      borderRadius: 8,
    },
    pillLabel: {
      fontFamily: fontFamily.monoBold,
      fontSize: 13,
    },
    detail: {
      paddingHorizontal: spacing.lg,
      paddingBottom: spacing.lg,
    },
    detailRow: {
      flexDirection: 'row',
      alignItems: 'center',
      marginBottom: spacing.sm,
    },
    detailLabel: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 11.5,
      color: t.colors.textDim,
      width: 30,
    },
    barWrap: {
      flex: 1,
      marginHorizontal: spacing.sm + 2,
    },
    detailValue: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 11.5,
      color: t.colors.textDim,
      width: 28,
      textAlign: 'right',
    },
    freqNote: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 10.5,
      color: t.colors.textFaint,
      paddingTop: spacing.sm,
      borderTopWidth: 1,
      borderTopColor: t.colors.line,
      borderStyle: 'dashed',
    },
  });
