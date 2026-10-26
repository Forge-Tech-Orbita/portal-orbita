import React, { useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { Feather, MaterialCommunityIcons } from '@expo/vector-icons';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { fontFamily, spacing } from '../constants';
import { Theme, ThemePreference, useColors, useTheme, useThemedStyles } from '../theme';
import { getProfile } from '../services';
import { useLogout } from '../hooks/useLogout';
import { useResource } from '../hooks/useResource';
import {
  Button,
  Chip,
  ErrorState,
  IdCard,
  LoadingState,
  ScreenContainer,
  ToggleSwitch,
  TopBar,
} from '../visual';
import { RootStackParamList } from '../navigation/types';

type Props = NativeStackScreenProps<RootStackParamList, 'Profile'>;

const appearanceOptions: { value: ThemePreference; label: string }[] = [
  { value: 'light', label: 'Claro' },
  { value: 'dark', label: 'Escuro' },
  { value: 'system', label: 'Sistema' },
];

/** Perfil do estudante: dados pessoais e preferências de conta. */
export function ProfileScreen({ navigation }: Props) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  const { preference, setPreference } = useTheme();
  const logout = useLogout();
  const [pushNotifications, setPushNotifications] = useState(true);
  const [faceId, setFaceId] = useState(false);
  const { data, loading, refreshing, error, reload } = useResource(getProfile);

  return (
    <ScreenContainer onRefresh={() => reload({ silent: true })} refreshing={refreshing}>
      <TopBar title="Meu perfil" onBack={navigation.goBack} showThemeToggle={false} />

      {loading && <LoadingState />}
      {!loading && error && <ErrorState message={error.message} onRetry={() => reload()} />}

      {!loading && !error && data && (
        <>
          <View style={styles.idCardWrap}>
            <IdCard student={data} showMeta={false} />
          </View>

          <View style={styles.list}>
            <View style={styles.row}>
              <View style={styles.rowLeft}>
                <MaterialCommunityIcons
                  name="card-account-details-outline"
                  size={16}
                  color={colors.cyan}
                />
                <Text style={styles.rowLabel}>CPF</Text>
              </View>
              <Text style={styles.rowValue}>{data.cpfMasked}</Text>
            </View>
            <View style={styles.row}>
              <View style={styles.rowLeft}>
                <Feather name="mail" size={16} color={colors.cyan} />
                <Text style={styles.rowLabel}>E-mail institucional</Text>
              </View>
              <Text style={styles.rowValue}>{data.institutionalEmail}</Text>
            </View>
            <View style={styles.row}>
              <View style={styles.rowLeft}>
                <Feather name="phone" size={16} color={colors.cyan} />
                <Text style={styles.rowLabel}>Telefone</Text>
              </View>
              <Text style={styles.rowValue}>{data.phoneMasked}</Text>
            </View>
            <View style={styles.row}>
              <View style={styles.rowLeft}>
                <Feather name="bell" size={16} color={colors.cyan} />
                <Text style={styles.rowLabel}>Notificações push</Text>
              </View>
              <ToggleSwitch
                value={pushNotifications}
                onValueChange={setPushNotifications}
                accessibilityLabel="Notificações push"
              />
            </View>

            <View style={[styles.row, styles.rowStacked]}>
              <View style={styles.rowLeft}>
                <Feather name="moon" size={16} color={colors.cyan} />
                <Text style={styles.rowLabel}>Aparência</Text>
              </View>
              <View style={styles.appearanceOptions}>
                {appearanceOptions.map((option) => (
                  <Chip
                    key={option.value}
                    label={option.label}
                    active={preference === option.value}
                    onPress={() => setPreference(option.value)}
                  />
                ))}
              </View>
            </View>

            <View style={[styles.row, styles.rowLast]}>
              <View style={styles.rowLeft}>
                <MaterialCommunityIcons name="face-recognition" size={16} color={colors.cyan} />
                <Text style={styles.rowLabel}>Biometria facial</Text>
              </View>
              <ToggleSwitch
                value={faceId}
                onValueChange={setFaceId}
                accessibilityLabel="Biometria facial"
              />
            </View>
          </View>

          <Button
            label="Encerrar sessão"
            variant="danger"
            style={styles.logoutButton}
            onPress={logout}
          />
        </>
      )}
    </ScreenContainer>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    idCardWrap: {
      marginBottom: spacing.md,
    },
    list: {
      marginTop: spacing.xl - 4,
    },
    row: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      paddingVertical: 14,
      borderBottomWidth: 1,
      borderBottomColor: t.colors.line,
      borderStyle: 'dashed',
    },
    // Três opções não cabem ao lado do rótulo em tela estreita, então esta
    // linha empilha em vez de disputar a largura.
    rowStacked: {
      flexDirection: 'column',
      alignItems: 'stretch',
      gap: spacing.md,
    },
    appearanceOptions: {
      flexDirection: 'row',
      gap: spacing.sm,
    },
    rowLast: {
      borderBottomWidth: 0,
    },
    rowLeft: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.md,
    },
    rowLabel: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 13,
      color: t.colors.text,
    },
    rowValue: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 11.5,
      color: t.colors.textDim,
    },
    logoutButton: {
      marginTop: spacing.xxl - 4,
    },
  });
