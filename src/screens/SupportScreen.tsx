import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { fontFamily, spacing } from '../constants';
import { Theme, useThemedStyles } from '../theme';
import { getFaq } from '../services';
import { useResource } from '../hooks/useResource';
import {
  Button,
  Card,
  ErrorState,
  LoadingState,
  ScreenContainer,
  SectionHeader,
  TopBar,
} from '../visual';
import { RootStackParamList } from '../navigation/types';

type Props = NativeStackScreenProps<RootStackParamList, 'Support'>;

/** Central de suporte: abertura de chamado e perguntas frequentes. */
export function SupportScreen({ navigation }: Props) {
  const styles = useThemedStyles(makeStyles);
  const { data, loading, refreshing, error, reload } = useResource(getFaq);

  return (
    <ScreenContainer onRefresh={() => reload({ silent: true })} refreshing={refreshing}>
      <TopBar title="Central de suporte" onBack={navigation.goBack} />

      <Card style={styles.contactCard}>
        <Text style={styles.eyebrow}>FALE COM A SECRETARIA</Text>
        <Text style={styles.description}>
          Abra um chamado para dúvidas sobre matrícula, documentos, aproveitamento de disciplinas ou
          requerimentos.
        </Text>
        <Button label="Abrir novo chamado" />
      </Card>

      <SectionHeader title="Perguntas frequentes" />

      {loading && <LoadingState />}
      {!loading && error && <ErrorState message={error.message} onRetry={() => reload()} />}

      {!loading && !error && data && (
        <Card>
          {data.map((entry, index, list) => (
            <View
              key={entry.question}
              style={[styles.faqRow, index === list.length - 1 && styles.faqRowLast]}
            >
              <Text style={styles.faqText}>
                <Text style={styles.faqQuestion}>{entry.question}</Text>
                {'\n'}
                {entry.answer}
              </Text>
            </View>
          ))}
        </Card>
      )}
    </ScreenContainer>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    contactCard: {
      marginBottom: spacing.lg,
    },
    eyebrow: {
      fontFamily: fontFamily.monoBold,
      fontSize: 10.5,
      letterSpacing: 1.5,
      color: t.colors.cyan,
      marginBottom: spacing.md,
    },
    description: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 12.5,
      color: t.colors.textDim,
      lineHeight: 19,
      marginBottom: spacing.lg - 2,
    },
    faqRow: {
      paddingVertical: 11,
      borderBottomWidth: 1,
      borderBottomColor: t.colors.line,
      borderStyle: 'dashed',
    },
    faqRowLast: {
      borderBottomWidth: 0,
    },
    faqText: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 12.5,
      color: t.colors.textDim,
      lineHeight: 19,
    },
    faqQuestion: {
      fontFamily: fontFamily.bodyBold,
      color: t.colors.text,
    },
  });
