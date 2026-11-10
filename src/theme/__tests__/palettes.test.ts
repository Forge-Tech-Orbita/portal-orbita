import { Palette, darkPalette, lightPalette, resolveScheme } from '../palettes';

const HEX = /^#[0-9A-Fa-f]{6}$/;
const RGBA = /^rgba\(\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*(0|1|0?\.\d+)\s*\)$/;

/** Luminância relativa da WCAG, para hex de 6 dígitos. */
function luminance(hex: string) {
  const channels = [1, 3, 5]
    .map((index) => parseInt(hex.slice(index, index + 2), 16) / 255)
    .map((value) => (value <= 0.03928 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4));
  return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2];
}

function contrast(foreground: string, background: string) {
  const [lighter, darker] = [luminance(foreground), luminance(background)].sort((a, b) => b - a);
  return (lighter + 0.05) / (darker + 0.05);
}

describe('paletas', () => {
  // O TypeScript garante que ambas cumprem `Palette`, mas não que os valores
  // sejam cores de verdade — um '#GG1122' passaria pelo compilador.
  function expectOnlyValidColors(palette: Palette) {
    for (const [token, value] of Object.entries(palette)) {
      const valid = HEX.test(value) || RGBA.test(value);
      if (!valid) throw new Error(`token "${token}" não é uma cor válida: ${value}`);
      expect(valid).toBe(true);
    }
  }

  it('a paleta clara só contém cores válidas', () => {
    expectOnlyValidColors(lightPalette);
  });

  it('a paleta escura só contém cores válidas', () => {
    expectOnlyValidColors(darkPalette);
  });

  it('as duas paletas expõem exatamente os mesmos tokens', () => {
    expect(Object.keys(darkPalette).sort()).toEqual(Object.keys(lightPalette).sort());
  });

  it('o tema escuro é escuro e o claro é claro', () => {
    expect(luminance(darkPalette.void)).toBeLessThan(luminance(lightPalette.void));
    expect(luminance(darkPalette.text)).toBeGreaterThan(luminance(lightPalette.text));
  });

  it('o texto principal do tema escuro tem contraste de sobra', () => {
    expect(contrast(darkPalette.text, darkPalette.void)).toBeGreaterThanOrEqual(4.5);
    expect(contrast(darkPalette.textDim, darkPalette.panel)).toBeGreaterThanOrEqual(4.5);
  });

  it('o texto sobre superfície preenchida continua legível nos dois temas', () => {
    expect(contrast(lightPalette.onText, lightPalette.text)).toBeGreaterThanOrEqual(4.5);
    expect(contrast(darkPalette.onText, darkPalette.text)).toBeGreaterThanOrEqual(4.5);
  });

  it('os destaques do tema escuro passam no mínimo para texto grande', () => {
    for (const accent of ['cyan', 'violet', 'mint', 'amber', 'rose'] as const) {
      expect(contrast(darkPalette[accent], darkPalette.panel)).toBeGreaterThanOrEqual(3);
    }
  });
});

describe('resolveScheme', () => {
  it('respeita a escolha explícita, ignorando o aparelho', () => {
    expect(resolveScheme('light', 'dark')).toBe('light');
    expect(resolveScheme('dark', 'light')).toBe('dark');
  });

  it('segue o aparelho quando a preferência é automática', () => {
    expect(resolveScheme('system', 'dark')).toBe('dark');
    expect(resolveScheme('system', 'light')).toBe('light');
  });

  // O aparelho pode não declarar preferência, e no web a informação pode faltar.
  it('cai no tema claro quando o aparelho não diz nada', () => {
    expect(resolveScheme('system', 'unspecified')).toBe('light');
    expect(resolveScheme('system', null)).toBe('light');
    expect(resolveScheme('system', undefined)).toBe('light');
  });
});
