import { Platform } from 'react-native';

/** Cores de destaque — usadas por dados (aulas, categorias) como token, não como hex. */
export type AccentToken = 'cyan' | 'violet' | 'mint' | 'amber' | 'rose';

/**
 * Contrato de cores do app. As duas paletas (clara e escura) preenchem
 * exatamente estas chaves, então qualquer tela pode trocar de tema sem
 * saber qual está ativo.
 */
export interface Palette {
  /** Fundo da tela ("papel"). */
  void: string;
  /** Superfície de card sobre o fundo. */
  panel: string;
  panel2: string;
  panel3: string;
  /** Fim do gradiente da carteirinha, partindo de `panel`. */
  panelGradientEnd: string;
  line: string;

  cyan: string;
  violet: string;
  mint: string;
  amber: string;
  rose: string;

  /** Versões translúcidas dos destaques, para pills, banners e badges. */
  cyanSoft: string;
  violetSoft: string;
  mintSoft: string;
  amberSoft: string;
  roseSoft: string;
  amberSoftBorder: string;
  roseSoftBorder: string;

  text: string;
  textDim: string;
  textFaint: string;
  /** Texto/ícone sobre uma superfície preenchida com `text` (botão primário, avatar). */
  onText: string;

  /** Bolinha do interruptor, desligado e ligado — precisa contrastar com os dois estados do trilho. */
  knobOff: string;
  knobOn: string;

  /** Cor base das sombras de papel. */
  shadowTint: string;
}

/** Paleta original "retrô-clean", espelhando o bloco :root de `docs/legacy/style.css`. */
export const lightPalette: Palette = {
  void: '#F6F1E3',
  panel: '#FBF8EF',
  panel2: '#F1E8D2',
  panel3: '#E8DCBC',
  panelGradientEnd: '#F8F3E5',
  line: '#DECBA0',

  cyan: '#2F6F68',
  violet: '#A6543B',
  mint: '#5B7F3A',
  amber: '#C98A2E',
  rose: '#AF3B2E',

  cyanSoft: 'rgba(47, 111, 104, 0.14)',
  violetSoft: 'rgba(166, 84, 59, 0.16)',
  mintSoft: 'rgba(91, 127, 58, 0.16)',
  amberSoft: 'rgba(201, 138, 46, 0.16)',
  roseSoft: 'rgba(175, 59, 46, 0.10)',
  amberSoftBorder: 'rgba(201, 138, 46, 0.35)',
  roseSoftBorder: 'rgba(175, 59, 46, 0.30)',

  text: '#2B2A22',
  textDim: '#6E6650',
  textFaint: '#A79A78',
  onText: '#FBF8EF',

  knobOff: '#FBF8EF',
  knobOn: '#FBF8EF',

  shadowTint: '#2B2A22',
};

/**
 * Contraparte noturna. Mantém o caráter sépia do tema claro — os cinzas puxam
 * para o quente e os destaques são clareados para continuarem legíveis sobre
 * fundo escuro (os tons originais, escuros e saturados, sumiriam).
 */
export const darkPalette: Palette = {
  void: '#16150F',
  panel: '#1F1D16',
  panel2: '#272419',
  panel3: '#332F21',
  panelGradientEnd: '#27241A',
  line: '#423C2A',

  cyan: '#63B5AB',
  violet: '#D98F6E',
  mint: '#96C167',
  amber: '#E5B45F',
  rose: '#E07A6A',

  cyanSoft: 'rgba(99, 181, 171, 0.16)',
  violetSoft: 'rgba(217, 143, 110, 0.18)',
  mintSoft: 'rgba(150, 193, 103, 0.18)',
  amberSoft: 'rgba(229, 180, 95, 0.18)',
  roseSoft: 'rgba(224, 122, 106, 0.14)',
  amberSoftBorder: 'rgba(229, 180, 95, 0.38)',
  roseSoftBorder: 'rgba(224, 122, 106, 0.34)',

  text: '#F2ECDA',
  textDim: '#B3AA90',
  textFaint: '#7E765F',
  onText: '#1F1D16',

  knobOff: '#B3AA90',
  knobOn: '#1F1D16',

  shadowTint: '#000000',
};

/**
 * Sombras equivalentes às variáveis `--shadow-sm` / `--shadow-md` / `--shadow-lift`
 * de `docs/legacy/style.css`, adaptadas para as APIs de sombra do iOS/Android.
 */
function paperShadow(tint: string, opacity: number, radiusPx: number, elevation: number) {
  return Platform.select({
    android: { elevation },
    default: {
      shadowColor: tint,
      shadowOffset: { width: 0, height: Math.round(radiusPx / 3) },
      shadowOpacity: opacity,
      shadowRadius: radiusPx,
    },
  });
}

export interface ShadowSet {
  sm: ReturnType<typeof paperShadow>;
  md: ReturnType<typeof paperShadow>;
  lift: ReturnType<typeof paperShadow>;
}

function makeShadows(tint: string): ShadowSet {
  return {
    sm: paperShadow(tint, 0.08, 6, 2),
    md: paperShadow(tint, 0.1, 12, 4),
    lift: paperShadow(tint, 0.22, 24, 10),
  };
}

export type ColorScheme = 'light' | 'dark';

/**
 * O que o usuário escolheu. Diferente de `ColorScheme`, que é o resultado já
 * resolvido: com 'system', quem decide é a configuração do aparelho.
 */
export type ThemePreference = ColorScheme | 'system';

/**
 * Traduz a preferência no modo que vai vigorar.
 *
 * O aparelho pode responder 'unspecified' (sem preferência declarada) ou nada,
 * quando a plataforma não expõe a informação; nos dois casos o app assume o
 * tema claro, que é o original do protótipo.
 */
export function resolveScheme(
  preference: ThemePreference,
  systemScheme: 'light' | 'dark' | 'unspecified' | null | undefined,
): ColorScheme {
  if (preference !== 'system') return preference;
  return systemScheme === 'dark' ? 'dark' : 'light';
}

/** O que um `makeStyles` recebe: cores da paleta ativa e as sombras casadas com ela. */
export interface Theme {
  scheme: ColorScheme;
  colors: Palette;
  shadow: ShadowSet;
}

export const lightTheme: Theme = {
  scheme: 'light',
  colors: lightPalette,
  shadow: makeShadows(lightPalette.shadowTint),
};

export const darkTheme: Theme = {
  scheme: 'dark',
  colors: darkPalette,
  shadow: makeShadows(darkPalette.shadowTint),
};
