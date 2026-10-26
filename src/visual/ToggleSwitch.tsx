import React, { useEffect, useState } from 'react';
import { Animated, Pressable, StyleSheet } from 'react-native';
import * as Haptics from 'expo-haptics';
import { Theme, useColors, useThemedStyles } from '../theme';

interface ToggleSwitchProps {
  value: boolean;
  onValueChange: (value: boolean) => void;
  /**
   * O que este interruptor controla. Sem isto o leitor de tela anuncia apenas
   * "ligado/desligado", sem dizer do quê — o rótulo visual fica numa `Text`
   * irmã, que a tecnologia assistiva não associa sozinha.
   */
  accessibilityLabel?: string;
}

/** Interruptor on/off usado na tela de Perfil (notificações, modo escuro, biometria). */
export function ToggleSwitch({ value, onValueChange, accessibilityLabel }: ToggleSwitchProps) {
  const styles = useThemedStyles(makeStyles);
  const colors = useColors();
  // Instância estável sem guardar ref: o valor animado nasce uma vez e
  // sobrevive aos renders, sem ser lido como `.current` durante o render.
  const [anim] = useState(() => new Animated.Value(value ? 1 : 0));

  // O valor pode mudar de fora (o tema também é alternado pelo atalho do
  // cabeçalho), então a animação acompanha a prop em vez de só o toque.
  useEffect(() => {
    Animated.timing(anim, {
      toValue: value ? 1 : 0,
      duration: 160,
      useNativeDriver: false,
    }).start();
  }, [anim, value]);

  const toggle = () => {
    Haptics.selectionAsync().catch(() => undefined);
    onValueChange(!value);
  };

  const dotLeft = anim.interpolate({ inputRange: [0, 1], outputRange: [2, 20] });
  const trackColor = anim.interpolate({
    inputRange: [0, 1],
    outputRange: [colors.panel3, colors.text],
  });
  // O trilho vai de claro a escuro no tema claro e o oposto no escuro, então a
  // bolinha também troca de cor — senão ela some contra o trilho em um dos estados.
  const dotColor = anim.interpolate({
    inputRange: [0, 1],
    outputRange: [colors.knobOff, colors.knobOn],
  });

  return (
    <Pressable
      onPress={toggle}
      hitSlop={8}
      accessibilityRole="switch"
      accessibilityState={{ checked: value }}
      accessibilityLabel={accessibilityLabel}
    >
      <Animated.View
        style={[
          styles.track,
          { backgroundColor: trackColor, borderColor: value ? colors.text : colors.line },
        ]}
      >
        <Animated.View style={[styles.dot, { left: dotLeft, backgroundColor: dotColor }]} />
      </Animated.View>
    </Pressable>
  );
}

const makeStyles = (_t: Theme) =>
  StyleSheet.create({
    track: {
      width: 40,
      height: 22,
      borderRadius: 20,
      borderWidth: 1,
      justifyContent: 'center',
    },
    dot: {
      position: 'absolute',
      width: 16,
      height: 16,
      borderRadius: 8,
    },
  });
