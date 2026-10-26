import React, { useState } from 'react';
import { Animated, Pressable, StyleSheet, Text, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { fontFamily, radius, spacing } from '../constants';
import { Theme, useColors, useThemedStyles } from '../theme';
import { StudentProfile } from '../types';
import { Barcode } from './Barcode';

interface IdCardProps {
  student: StudentProfile;
  /** Quando `false`, oculta o rodapé com matrícula/validade/código de barras (usado no Perfil). */
  showMeta?: boolean;
}

/**
 * Carteirinha digital — elemento assinatura do app. Ao ser pressionada, inclina-se
 * levemente em 3D, um eco do efeito de tilt por mouse/touch do protótipo original
 * (aqui acionado por toque, e não por arraste contínuo, para não brigar com o
 * scroll da tela quando o card está dentro de uma lista rolável).
 */
export function IdCard({ student, showMeta = true }: IdCardProps) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  const [tilt] = useState(() => new Animated.Value(0));

  const animateTo = (toValue: number) => {
    Animated.spring(tilt, { toValue, useNativeDriver: true, friction: 6 }).start();
  };

  const rotateX = tilt.interpolate({ inputRange: [0, 1], outputRange: ['0deg', '-3deg'] });
  const rotateY = tilt.interpolate({ inputRange: [0, 1], outputRange: ['0deg', '3deg'] });
  const scale = tilt.interpolate({ inputRange: [0, 1], outputRange: [1, 1.015] });

  return (
    <Pressable onPressIn={() => animateTo(1)} onPressOut={() => animateTo(0)}>
      <Animated.View
        style={[
          styles.card,
          { transform: [{ perspective: 900 }, { rotateX }, { rotateY }, { scale }] },
        ]}
      >
        <LinearGradient
          colors={[colors.panel, colors.panelGradientEnd]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={StyleSheet.absoluteFill}
        />
        <View style={styles.dashedRule} />

        <View style={styles.top}>
          <Text style={styles.org}>◈ INSTITUTO ÓRBITA</Text>
          <View style={styles.chip} />
        </View>

        <View style={styles.body}>
          <View style={styles.avatar}>
            <Text style={styles.avatarLabel}>{student.initials}</Text>
          </View>
          <View style={styles.info}>
            <Text style={styles.name}>{student.fullName}</Text>
            <Text style={styles.course}>{student.course}</Text>
          </View>
        </View>

        {showMeta && (
          <View style={styles.meta}>
            <View>
              <Text style={styles.metaLabel}>Matrícula</Text>
              <Text style={styles.metaValue}>{student.registration}</Text>
            </View>
            <View>
              <Text style={styles.metaLabel}>Validade</Text>
              <Text style={styles.metaValue}>{student.validUntil}</Text>
            </View>
            <Barcode bars={14} minHeight={6} maxHeight={18} />
          </View>
        )}

        <View style={styles.activeBadge}>
          <Text style={styles.activeBadgeLabel}>ATIVO</Text>
        </View>
      </Animated.View>
    </Pressable>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    card: {
      borderRadius: radius.lg,
      borderWidth: 1.5,
      borderColor: t.colors.line,
      paddingVertical: spacing.lg,
      paddingHorizontal: spacing.lg + 2,
      overflow: 'hidden',
      ...t.shadow.md,
    },
    dashedRule: {
      position: 'absolute',
      left: 12,
      top: 10,
      bottom: 10,
      borderLeftWidth: 2,
      borderStyle: 'dashed',
      borderColor: t.colors.textFaint,
      opacity: 0.55,
    },
    top: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'flex-start',
      paddingLeft: spacing.lg - 2,
    },
    org: {
      fontFamily: fontFamily.display,
      fontSize: 15,
      letterSpacing: 1.4,
      color: t.colors.text,
    },
    chip: {
      width: 28,
      height: 28,
      borderRadius: 14,
      backgroundColor: t.colors.panel2,
      borderWidth: 1.5,
      borderStyle: 'dashed',
      borderColor: t.colors.cyan,
    },
    body: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.md,
      marginTop: spacing.lg,
      paddingLeft: spacing.lg - 2,
    },
    avatar: {
      width: 52,
      height: 52,
      borderRadius: radius.sm + 4,
      backgroundColor: t.colors.text,
      alignItems: 'center',
      justifyContent: 'center',
      ...t.shadow.sm,
    },
    avatarLabel: {
      fontFamily: fontFamily.display,
      fontSize: 19,
      color: t.colors.onText,
    },
    info: {
      flex: 1,
    },
    name: {
      fontFamily: fontFamily.bodyBold,
      fontSize: 15,
      color: t.colors.text,
    },
    course: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 11.5,
      color: t.colors.textDim,
      marginTop: 2,
    },
    meta: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'flex-end',
      marginTop: spacing.lg,
      paddingLeft: spacing.lg - 2,
    },
    metaLabel: {
      fontFamily: fontFamily.monoRegular,
      fontSize: 9,
      color: t.colors.textFaint,
      letterSpacing: 1,
      textTransform: 'uppercase',
    },
    metaValue: {
      fontFamily: fontFamily.monoBold,
      fontSize: 12,
      color: t.colors.text,
      marginTop: 2,
    },
    activeBadge: {
      position: 'absolute',
      bottom: 10,
      right: 12,
      width: 48,
      height: 48,
      borderRadius: 24,
      borderWidth: 1.5,
      borderStyle: 'dashed',
      borderColor: t.colors.rose,
      alignItems: 'center',
      justifyContent: 'center',
      transform: [{ rotate: '-11deg' }],
      opacity: 0.8,
    },
    activeBadgeLabel: {
      fontFamily: fontFamily.monoBold,
      fontSize: 8.5,
      letterSpacing: 1,
      color: t.colors.rose,
      textAlign: 'center',
    },
  });
