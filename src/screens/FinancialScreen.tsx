import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { fontFamily, spacing } from '../constants';
import { Theme, useColors, useThemedStyles } from '../theme';
import { getFinancial } from '../services';
import { useResource } from '../hooks/useResource';
import {
  Barcode,
  Button,
  Card,
  ErrorState,
  LoadingState,
  ScreenContainer,
  SectionHeader,
  TopBar,
} from '../visual';
import { RootStackParamList } from '../navigation/types';

type Props = NativeStackScreenProps<RootStackParamList, 'Financial'>;

/** Área financeira: fatura em aberto, código de barras e histórico de pagamentos. */
export function FinancialScreen({ navigation }: Props) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  const { data, loading, refreshing, error, reload } = useResource(getFinancial);

  return (
    <ScreenContainer onRefresh={() => reload({ silent: true })} refreshing={refreshing}>
      <TopBar title="Financeiro" onBack={navigation.goBack} />

      {loading && <LoadingState />}
      {!loading && error && <ErrorState message={error.message} onRetry={() => reload()} />}

      {!loading && !error && data && (
        <>
          <View style={styles.banner}>
            <Feather name="alert-triangle" size={20} color={colors.amber} />
            <View>
              <Text style={styles.bannerTitle}>Fatura em aberto</Text>
              <Text style={styles.bannerSubtitle}>Vencimento em {data.invoice.dueDate}</Text>
            </View>
          </View>

          <Card style={styles.invoiceCard}>
            <Text style={styles.invoiceEyebrow}>{data.invoice.referenceLabel}</Text>
            <View style={styles.invoiceRow}>
              <Text style={styles.invoiceLabel}>Valor</Text>
              <Text style={styles.invoiceValue}>{data.invoice.amount}</Text>
            </View>
            <View style={styles.invoiceRow}>
              <Text style={styles.invoiceLabel}>Vencimento</Text>
              <Text style={styles.invoiceValue}>{data.invoice.dueDate}</Text>
            </View>
            <View style={styles.invoiceRow}>
              <Text style={styles.invoiceLabel}>Desconto pontualidade</Text>
              <Text style={[styles.invoiceValue, { color: colors.mint }]}>
                {data.invoice.punctualityDiscount}
              </Text>
            </View>
            <View style={styles.barcodeStrip}>
              <Barcode bars={46} minHeight={6} maxHeight={34} />
            </View>
            <Button label="Gerar 2ª via" />
          </Card>

          <SectionHeader title="Histórico de pagamentos" />
          <Card>
            {data.history.map((entry, index, list) => (
              <View
                key={entry.month}
                style={[styles.historyRow, index === list.length - 1 && styles.historyRowLast]}
              >
                <Text style={styles.historyMonth}>{entry.month}</Text>
                <Text style={styles.historyAmount}>{entry.amount}</Text>
              </View>
            ))}
          </Card>
        </>
      )}
    </ScreenContainer>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    banner: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.md,
      padding: 14,
      borderRadius: 14,
      backgroundColor: t.colors.amberSoft,
      borderWidth: 1,
      borderColor: t.colors.amberSoftBorder,
      marginBottom: spacing.xl - 2,
    },
    bannerTitle: {
      fontFamily: fontFamily.bodyBold,
      fontSize: 13.5,
      color: t.colors.amber,
    },
    bannerSubtitle: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 11,
      color: t.colors.textDim,
      marginTop: 2,
    },
    invoiceCard: {
      marginBottom: spacing.xl,
    },
    invoiceEyebrow: {
      fontFamily: fontFamily.monoBold,
      fontSize: 10.5,
      letterSpacing: 1.5,
      color: t.colors.cyan,
      marginBottom: spacing.md,
    },
    invoiceRow: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      marginBottom: spacing.sm + 2,
    },
    invoiceLabel: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 12.5,
      color: t.colors.textDim,
    },
    invoiceValue: {
      fontFamily: fontFamily.monoBold,
      fontSize: 12.5,
      color: t.colors.text,
    },
    barcodeStrip: {
      alignItems: 'center',
      marginVertical: spacing.md + 2,
    },
    historyRow: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      paddingVertical: 11,
      borderBottomWidth: 1,
      borderBottomColor: t.colors.line,
      borderStyle: 'dashed',
    },
    historyRowLast: {
      borderBottomWidth: 0,
    },
    historyMonth: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 12,
      color: t.colors.textDim,
    },
    historyAmount: {
      fontFamily: fontFamily.monoBold,
      fontSize: 12,
      color: t.colors.mint,
    },
  });
