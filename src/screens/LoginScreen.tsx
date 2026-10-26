import React, { useState } from 'react';
import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { Feather, MaterialCommunityIcons } from '@expo/vector-icons';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { fontFamily, spacing } from '../constants';
import { Theme, useColors, useThemedStyles } from '../theme';
import { signIn, validateCredentials } from '../services';
import { Button, OrbitMark, ThemeToggle } from '../visual';
import { RootStackParamList } from '../navigation/types';

type Props = NativeStackScreenProps<RootStackParamList, 'Login'>;

/** Porta de entrada do app — autenticação simulada contra `services/auth`. */
export function LoginScreen({ navigation }: Props) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  const [registration, setRegistration] = useState('2023104567');
  const [password, setPassword] = useState('');
  const [authenticating, setAuthenticating] = useState(false);
  const [problem, setProblem] = useState<string | null>(null);

  /** Some com o aviso assim que o usuário mexe no campo — senão ele fica acusando algo já corrigido. */
  const edit = (setter: (value: string) => void) => (value: string) => {
    setProblem(null);
    setter(value);
  };

  const handleLogin = async () => {
    if (authenticating) return;

    const credentials = { registration, password };

    // Validação local primeiro: campo vazio não merece uma ida ao servidor.
    const localProblem = validateCredentials(credentials);
    if (localProblem) {
      setProblem(localProblem);
      return;
    }

    setProblem(null);
    setAuthenticating(true);
    try {
      await signIn(credentials);
      navigation.reset({ index: 0, routes: [{ name: 'Main' }] });
    } catch (cause) {
      setProblem(cause instanceof Error ? cause.message : 'Não foi possível entrar.');
    } finally {
      setAuthenticating(false);
    }
  };

  return (
    <View style={styles.screen}>
      <View style={styles.toggleRow}>
        <ThemeToggle />
      </View>

      <View style={styles.logoBlock}>
        <OrbitMark size={64} />
        <Text style={styles.title}>ÓRBITA</Text>
        <Text style={styles.subtitle}>ENSINO EM OUTRA ÓRBITA</Text>
      </View>

      <View style={styles.field}>
        <Text style={styles.label}>Matrícula</Text>
        <TextInput
          value={registration}
          onChangeText={edit(setRegistration)}
          placeholder="2023104567"
          placeholderTextColor={colors.textFaint}
          style={styles.input}
          keyboardType="number-pad"
          accessibilityLabel="Matrícula"
        />
      </View>
      <View style={styles.field}>
        <Text style={styles.label}>Senha de acesso</Text>
        <TextInput
          value={password}
          onChangeText={edit(setPassword)}
          placeholder="••••••••"
          placeholderTextColor={colors.textFaint}
          style={styles.input}
          secureTextEntry
          accessibilityLabel="Senha de acesso"
        />
      </View>

      {problem && (
        <View style={styles.problemRow} accessibilityRole="alert">
          <Feather name="alert-circle" size={14} color={colors.rose} />
          <Text style={styles.problemText}>{problem}</Text>
        </View>
      )}

      <Button
        label={authenticating ? 'AUTENTICANDO...' : 'ENTRAR NO PORTAL'}
        icon={authenticating ? undefined : 'arrow-right'}
        loading={authenticating}
        onPress={handleLogin}
      />

      <Pressable
        style={styles.bioRow}
        onPress={handleLogin}
        hitSlop={8}
        accessibilityRole="button"
        accessibilityLabel="Acessar com biometria"
      >
        <MaterialCommunityIcons name="fingerprint" size={16} color={colors.violet} />
        <Text style={styles.bioLabel}>Acessar com biometria</Text>
      </Pressable>

      <Text style={styles.footer}>
        INSTITUTO ÓRBITA · SISTEMA ACADÊMICO v3.2{'\n'}CONEXÃO CRIPTOGRAFADA · REDE INTEGRADA
      </Text>
    </View>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    screen: {
      flex: 1,
      backgroundColor: t.colors.void,
      paddingHorizontal: 20,
      paddingTop: 56,
      paddingBottom: 32,
      justifyContent: 'flex-start',
    },
    toggleRow: {
      alignItems: 'flex-end',
    },
    logoBlock: {
      alignItems: 'center',
      marginBottom: spacing.xxl + 6,
    },
    title: {
      fontFamily: fontFamily.display,
      fontSize: 34,
      letterSpacing: 3,
      color: t.colors.text,
      marginTop: spacing.md,
    },
    subtitle: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 10.5,
      color: t.colors.textDim,
      letterSpacing: 2,
      marginTop: 2,
    },
    field: {
      marginBottom: spacing.lg,
    },
    label: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 11,
      color: t.colors.textDim,
      letterSpacing: 1,
      textTransform: 'uppercase',
      marginBottom: spacing.xs + 2,
    },
    input: {
      backgroundColor: t.colors.panel,
      borderWidth: 1.5,
      borderColor: t.colors.line,
      borderRadius: 12,
      paddingVertical: 13,
      paddingHorizontal: 14,
      color: t.colors.text,
      fontFamily: fontFamily.monoRegular,
      fontSize: 14,
    },
    problemRow: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.sm,
      backgroundColor: t.colors.roseSoft,
      borderWidth: 1,
      borderColor: t.colors.roseSoftBorder,
      borderRadius: 10,
      paddingVertical: 10,
      paddingHorizontal: 12,
      marginBottom: spacing.lg,
    },
    problemText: {
      flex: 1,
      fontFamily: fontFamily.bodyRegular,
      fontSize: 12,
      color: t.colors.rose,
      lineHeight: 17,
    },
    bioRow: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
      gap: spacing.sm,
      marginTop: spacing.lg,
    },
    bioLabel: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 12,
      color: t.colors.textDim,
    },
    footer: {
      marginTop: 'auto',
      textAlign: 'center',
      fontFamily: fontFamily.monoRegular,
      fontSize: 10.5,
      color: t.colors.textFaint,
      lineHeight: 18,
      paddingTop: spacing.xl,
    },
  });
