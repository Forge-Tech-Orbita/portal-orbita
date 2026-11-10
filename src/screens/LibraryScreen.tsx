import React, { useState } from 'react';
import { ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { fontFamily, radius, spacing } from '../constants';
import { Palette, Theme, useColors, useThemedStyles } from '../theme';
import { getLibrary } from '../services';
import { useResource } from '../hooks/useResource';
import { DueStatus } from '../types';
import {
  Chip,
  ErrorState,
  LoadingState,
  SectionHeader,
  ScreenContainer,
  TopBar,
} from '../visual';
import { RootStackParamList } from '../navigation/types';

type Props = NativeStackScreenProps<RootStackParamList, 'Library'>;

/** Verde quando o prazo está folgado, vermelho quando aperta. */
function dueTone(colors: Palette, status: DueStatus) {
  return status === 'ok'
    ? { fg: colors.mint, bg: colors.mintSoft }
    : { fg: colors.rose, bg: colors.roseSoft };
}

/** Biblioteca: busca, categorias e lista de empréstimos ativos. */
export function LibraryScreen({ navigation }: Props) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  const [query, setQuery] = useState('');
  const [chosenCategory, setChosenCategory] = useState<string | null>(null);
  const { data, loading, refreshing, error, reload } = useResource(getLibrary);

  // A primeira categoria só é conhecida quando o servidor responde. Derivar
  // evita um efeito que existiria apenas para copiar dado para dentro do estado.
  const activeCategory = chosenCategory ?? data?.categories[0] ?? null;

  return (
    <ScreenContainer onRefresh={() => reload({ silent: true })} refreshing={refreshing}>
      <TopBar title="Biblioteca" onBack={navigation.goBack} />

      {loading && <LoadingState />}
      {!loading && error && <ErrorState message={error.message} onRetry={() => reload()} />}

      {!loading && !error && data && (
        <>
          <View style={styles.searchBox}>
            <Feather name="search" size={16} color={colors.textDim} />
            <TextInput
              value={query}
              onChangeText={setQuery}
              placeholder="Buscar título, autor ou ISBN..."
              placeholderTextColor={colors.textFaint}
              style={styles.searchInput}
              accessibilityLabel="Buscar no acervo"
            />
          </View>

          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.categoryRow}
          >
            {data.categories.map((category) => (
              <Chip
                key={category}
                label={category}
                active={category === activeCategory}
                onPress={() => setChosenCategory(category)}
              />
            ))}
          </ScrollView>

          <SectionHeader title="Meus empréstimos" />
          {data.loans.map((book) => {
            const tone = dueTone(colors, book.dueStatus);
            return (
              <View key={book.id} style={styles.bookRow}>
                <View style={styles.cover} />
                <View style={styles.bookInfo}>
                  <Text style={styles.bookTitle}>{book.title}</Text>
                  <Text style={styles.bookAuthor}>{book.author}</Text>
                </View>
                <View style={[styles.duePill, { backgroundColor: tone.bg }]}>
                  <Text style={[styles.dueLabel, { color: tone.fg }]}>{book.dueLabel}</Text>
                </View>
              </View>
            );
          })}
        </>
      )}
    </ScreenContainer>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    searchBox: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.sm + 2,
      backgroundColor: t.colors.panel,
      borderWidth: 1,
      borderColor: t.colors.line,
      borderRadius: radius.md,
      paddingVertical: 12,
      paddingHorizontal: 14,
      marginBottom: spacing.xl - 2,
      ...t.shadow.sm,
    },
    searchInput: {
      flex: 1,
      fontFamily: fontFamily.monoRegular,
      fontSize: 13,
      color: t.colors.text,
    },
    categoryRow: {
      gap: spacing.sm,
      marginBottom: spacing.xl,
    },
    bookRow: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.md,
      marginBottom: spacing.lg - 2,
    },
    cover: {
      width: 42,
      height: 56,
      borderRadius: 4,
      backgroundColor: t.colors.violet,
      ...t.shadow.sm,
    },
    bookInfo: {
      flex: 1,
    },
    bookTitle: {
      fontFamily: fontFamily.bodyBold,
      fontSize: 13,
      color: t.colors.text,
    },
    bookAuthor: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 11,
      color: t.colors.textDim,
      marginTop: 2,
    },
    duePill: {
      paddingVertical: 4,
      paddingHorizontal: 8,
      borderRadius: 7,
    },
    dueLabel: {
      fontFamily: fontFamily.monoBold,
      fontSize: 10.5,
    },
  });
