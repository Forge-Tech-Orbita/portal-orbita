import { BebasNeue_400Regular } from '@expo-google-fonts/bebas-neue';
import {
  WorkSans_400Regular,
  WorkSans_500Medium,
  WorkSans_600SemiBold,
  WorkSans_700Bold,
} from '@expo-google-fonts/work-sans';
import { CourierPrime_400Regular, CourierPrime_700Bold } from '@expo-google-fonts/courier-prime';

/**
 * Famílias de fonte usadas no app. As chaves espelham o que `useFonts`
 * (chamado em `App.tsx`) registra depois do carregamento.
 */
export const fontFamily = {
  display: 'BebasNeue_400Regular',
  bodyRegular: 'WorkSans_400Regular',
  bodyMedium: 'WorkSans_500Medium',
  bodySemiBold: 'WorkSans_600SemiBold',
  bodyBold: 'WorkSans_700Bold',
  monoRegular: 'CourierPrime_400Regular',
  monoBold: 'CourierPrime_700Bold',
} as const;

/** Mapa passado diretamente para `useFonts()` no compositor (`App.tsx`). */
export const fontsToLoad = {
  BebasNeue_400Regular,
  WorkSans_400Regular,
  WorkSans_500Medium,
  WorkSans_600SemiBold,
  WorkSans_700Bold,
  CourierPrime_400Regular,
  CourierPrime_700Bold,
};
