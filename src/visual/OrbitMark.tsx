import React from 'react';
import Svg, { Circle, Ellipse } from 'react-native-svg';
import { useColors } from '../theme';

/** Marca "Órbita" — três elipses cruzadas simulando trajetórias orbitais. */
export function OrbitMark({ size = 64 }: { size?: number }) {
  const colors = useColors();
  return (
    <Svg width={size} height={size} viewBox="0 0 64 64" fill="none">
      <Circle cx={32} cy={32} r={30} fill={colors.panel} stroke={colors.line} strokeWidth={1} />
      <Circle cx={32} cy={32} r={25} fill="none" stroke={colors.text} strokeWidth={1.2} strokeDasharray="2.5 3" />
      <Circle cx={32} cy={32} r={5.5} fill={colors.text} />
      <Ellipse cx={32} cy={32} rx={21} ry={9} stroke={colors.text} strokeWidth={1.3} opacity={0.85} />
      <Ellipse
        cx={32}
        cy={32}
        rx={21}
        ry={9}
        stroke={colors.violet}
        strokeWidth={1.3}
        opacity={0.85}
        rotation={60}
        origin="32, 32"
      />
      <Ellipse
        cx={32}
        cy={32}
        rx={21}
        ry={9}
        stroke={colors.amber}
        strokeWidth={1.3}
        opacity={0.85}
        rotation={120}
        origin="32, 32"
      />
    </Svg>
  );
}
