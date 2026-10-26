import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import Svg, { Circle, Defs, LinearGradient, Stop } from 'react-native-svg';
import { fontFamily } from '../constants';
import { Theme, useColors, useThemedStyles } from '../theme';

interface GpaRingProps {
  value: number;
  maxValue?: number;
  label?: string;
  size?: number;
}

/** Anel de progresso circular exibindo o CRA — equivalente ao `.gpa-ring` original. */
export function GpaRing({ value, maxValue = 10, label = 'CRA', size = 96 }: GpaRingProps) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  const strokeWidth = 8;
  const radiusPx = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radiusPx;
  const progress = Math.max(0, Math.min(1, value / maxValue));
  const dashOffset = circumference * (1 - progress);

  return (
    <View style={{ width: size, height: size }}>
      <Svg width={size} height={size} style={styles.rotated}>
        <Defs>
          <LinearGradient id="gpaGradient" x1="0" y1="0" x2="1" y2="1">
            <Stop offset="0%" stopColor="#00e5ff" />
            <Stop offset="100%" stopColor="#8b6bff" />
          </LinearGradient>
        </Defs>
        <Circle
          cx={size / 2}
          cy={size / 2}
          r={radiusPx}
          stroke={colors.panel3}
          strokeWidth={strokeWidth}
          fill="none"
        />
        <Circle
          cx={size / 2}
          cy={size / 2}
          r={radiusPx}
          stroke="url(#gpaGradient)"
          strokeWidth={strokeWidth}
          fill="none"
          strokeLinecap="round"
          strokeDasharray={`${circumference} ${circumference}`}
          strokeDashoffset={dashOffset}
        />
      </Svg>
      <View style={styles.center}>
        <Text style={styles.value}>{value.toFixed(1)}</Text>
        <Text style={styles.label}>{label}</Text>
      </View>
    </View>
  );
}

const makeStyles = (t: Theme) =>
  StyleSheet.create({
    rotated: {
      transform: [{ rotate: '-90deg' }],
    },
    center: {
      ...StyleSheet.absoluteFill,
      alignItems: 'center',
      justifyContent: 'center',
    },
    value: {
      fontFamily: fontFamily.monoBold,
      fontSize: 21,
      color: t.colors.text,
    },
    label: {
      fontFamily: fontFamily.bodyRegular,
      fontSize: 8.5,
      color: t.colors.textFaint,
      letterSpacing: 1,
      marginTop: 2,
    },
  });
