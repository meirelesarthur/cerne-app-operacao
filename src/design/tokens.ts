/**
 * GB CERNE — Design Tokens (fonte única de verdade)
 * =================================================
 * Arquitetura em 3 camadas, alinhada ao padrão W3C DTCG (Design Tokens Community Group):
 *   1. primitive  — valores crus (paletas, escalas numéricas)
 *   2. semantic   — papéis (feedback, accent, state) + theme-aware (light | gbMode)
 *   3. foundation/component — font, space, size, radius, shadow, dashboardTile, ...
 *
 * REGRAS (CLAUDE.md — Leis 3 e 5):
 *  - Nenhum valor de design hardcoded fora deste arquivo. Telas/componentes consomem via `t.*`.
 *  - Ao alterar este arquivo, rodar `npm run tokens:export` e commitar `tokens/tokens.json`
 *    (DTCG) na mesma unidade lógica. O código define; Figma/Supernova consomem.
 *  - Única família tipográfica permitida: Outfit.
 */

/* ------------------------------------------------------------------ *
 * 1. PRIMITIVOS
 * ------------------------------------------------------------------ */

export const primitive = {
  brand: {
    50: '#f0fdf4',
    100: '#dcfce7',
    200: '#bbf7d0',
    300: '#86efac',
    400: '#4ade80',
    500: '#22c55e',
    600: '#059669', // cor de marca principal (accent/CTA)
    700: '#047857', // hover
    800: '#065f46',
    900: '#064e3b',
  },
  neutral: {
    0: '#ffffff',
    50: '#fafafa',
    100: '#f5f5f5',
    150: '#f3f4f6',
    200: '#e5e7eb',
    250: '#e5e5e5',
    300: '#d1d5db',
    400: '#9ca3af',
    500: '#6b7280',
    600: '#616161',
    700: '#404040',
    800: '#1a1a1a',
    900: '#111827',
    950: '#171717',
  },
  red: {
    50: '#fef2f2',
    100: '#fee2e2',
    200: '#fecaca',
    300: '#fca5a5',
    400: '#f87171',
    500: '#ef4444',
    600: '#dc2626',
    700: '#b91c1c',
    800: '#991b1b',
    900: '#7f1d1d',
  },
  amber: {
    50: '#fffbeb',
    100: '#fef3c7',
    200: '#fde68a',
    300: '#fcd34d',
    400: '#fbbf24',
    500: '#f59e0b',
    600: '#d97706',
    700: '#b45309',
    800: '#92400e',
    900: '#78350f',
  },
  blue: {
    50: '#eff6ff',
    100: '#dbeafe',
    200: '#bfdbfe',
    300: '#93c5fd',
    400: '#60a5fa',
    500: '#3b82f6',
    600: '#2563eb',
    700: '#1d4ed8',
    800: '#1e40af',
    900: '#1e3a8a',
  },
} as const

/* ------------------------------------------------------------------ *
 * 2. SEMÂNTICO
 * ------------------------------------------------------------------ */

// 2a. theme-agnostic — papéis que não mudam entre light/gbMode
const feedback = {
  success: { bg: primitive.brand[50], border: primitive.brand[200], text: primitive.brand[700], solid: primitive.brand[600] },
  error: { bg: primitive.red[50], border: primitive.red[200], text: primitive.red[600], solid: primitive.red[500] },
  warning: { bg: primitive.amber[50], border: primitive.amber[200], text: primitive.amber[600], solid: primitive.amber[500] },
  info: { bg: primitive.blue[50], border: primitive.blue[200], text: primitive.blue[600], solid: primitive.blue[500] },
  notice: primitive.amber[500],
} as const

const accent = {
  purple: { bg: '#f5f3ff', solid: '#7c3aed', border: '#ddd6fe' },
  cyan: { bg: '#ecfeff', solid: '#0891b2', border: '#a5f3fc' },
} as const

const state = {
  disabled: { bg: primitive.neutral[100], text: primitive.neutral[400], border: primitive.neutral[200] },
  readonly: { bg: primitive.neutral[50], text: primitive.neutral[600] },
  row: { hover: primitive.neutral[50], selected: primitive.brand[50], striped: primitive.neutral[50] },
} as const

const overlay = {
  modal: 'rgba(17, 24, 39, 0.45)',
  drawer: 'rgba(17, 24, 39, 0.35)',
} as const

const gb = {
  accent: '#4ade80',
  surface: 'rgba(14, 42, 29, 0.55)',
} as const

export const color = {
  ...primitive,
  feedback,
  accent,
  state,
  overlay,
  gb,
} as const

// 2b. theme-aware — consumido via ThemeContext / useTheme()
export interface ThemePalette {
  fg: { default: string; muted: string; subtle: string; inverse: string }
  bg: { canvas: string; surface: string; subtle: string; raised: string; kpi: string }
  border: { default: string; strong: string; subtle: string; tint: string }
  accent: { default: string; hover: string; subtle: string; contrast: string }
  nav: { bg: string; fg: string; active: string; border: string }
  shadow: { card: string; cardHover: string; modal: string }
}

export const themePalette: Record<'light' | 'gbMode', ThemePalette> = {
  light: {
    fg: { default: primitive.neutral[900], muted: primitive.neutral[500], subtle: primitive.neutral[400], inverse: primitive.neutral[0] },
    bg: { canvas: '#f5f5f5', surface: primitive.neutral[0], subtle: primitive.neutral[50], raised: primitive.neutral[0], kpi: '#f8fffe' },
    border: { default: primitive.neutral[200], strong: primitive.neutral[300], subtle: primitive.neutral[150], tint: primitive.brand[100] },
    accent: { default: primitive.brand[600], hover: primitive.brand[700], subtle: primitive.brand[50], contrast: primitive.neutral[0] },
    nav: { bg: primitive.brand[900], fg: '#d1fae5', active: '#4ade80', border: 'rgba(255,255,255,0.12)' },
    shadow: {
      card: 'none',
      cardHover: '0 2px 12px rgba(0,0,0,0.06)',
      modal: '0 20px 48px rgba(0,0,0,0.24)',
    },
  },
  gbMode: {
    fg: { default: '#e2f0e8', muted: '#8fb3a2', subtle: '#5f7d6e', inverse: '#051008' },
    bg: { canvas: '#051008', surface: '#0e2a1d', subtle: '#0a2016', raised: '#123a28', kpi: '#0e2a1d' },
    border: { default: 'rgba(255,255,255,0.10)', strong: 'rgba(255,255,255,0.18)', subtle: 'rgba(255,255,255,0.06)', tint: 'rgba(255,255,255,0.10)' },
    accent: { default: '#10b981', hover: '#34d399', subtle: 'rgba(16,185,129,0.14)', contrast: '#051008' },
    nav: { bg: '#081a12', fg: '#8fb3a2', active: '#4ade80', border: 'rgba(255,255,255,0.10)' },
    shadow: {
      card: '0 1px 3px rgba(0,0,0,0.4)',
      cardHover: '0 6px 16px rgba(0,0,0,0.5)',
      modal: '0 20px 48px rgba(0,0,0,0.6)',
    },
  },
}

/* ------------------------------------------------------------------ *
 * 3. FUNDAÇÃO (não-cor)
 * ------------------------------------------------------------------ */

export const font = {
  family: { sans: "'Outfit', sans-serif" },
  size: {
    xs: '11px',
    sm: '12px',
    base: '13px',
    md: '14px',
    lg: '15px',
    xl: '16px',
    '2xl': '22px',
    '3xl': '26px',
    '4xl': '32px',
  },
  weight: { normal: 400, medium: 500, semibold: 600, bold: 700, extrabold: 800 },
  lineHeight: { tight: 1.2, snug: 1.35, normal: 1.5, relaxed: 1.625 },
} as const

// escala de espaço base 4px (keys alinhadas ao Tailwind)
export const space = {
  0: '0px',
  1: '4px',
  2: '8px',
  3: '12px',
  4: '16px',
  5: '20px',
  6: '24px',
  7: '28px',
  8: '32px',
  9: '36px',
  10: '40px',
  12: '48px',
  14: '56px',
  16: '64px',
  20: '80px',
} as const

export const size = {
  control: '40px',
  controlSm: '32px',
  controlLg: '48px',
  btn: { sm: '32px', md: '40px', lg: '48px' },
  iconBtn: { sm: '24px', md: '30px', lg: '36px' },
  toggle: { track: '40px', thumb: '18px' },
  tableRow: '42px',
  drawer: '320px',
  tabBar: '64px', // altura do bottom tab bar (mobile)
  phone: '420px', // largura máxima do frame de telefone
} as const

export const radius = {
  sm: '4px',
  md: '6px',
  base: '8px',
  lg: '10px',
  xl: '12px',
  '2xl': '16px',
  '3xl': '20px',
  '4xl': '24px',
  modal: '20px',
  full: '9999px',
} as const

export const shadow = {
  sm: '0 1px 2px rgba(0,0,0,0.05)',
  base: '0 1px 3px rgba(0,0,0,0.1)',
  md: '0 4px 6px rgba(0,0,0,0.07)',
  lg: '0 10px 20px rgba(0,0,0,0.12)',
  brand: '0 6px 16px rgba(5,150,105,0.30)',
  overlay: '0 12px 32px rgba(0,0,0,0.18)',
  modal: '0 20px 48px rgba(0,0,0,0.24)',
  card: '0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)',
  cardHover: '0 4px 12px rgba(0,0,0,0.08)',
} as const

export const border = {
  base: `1px solid ${primitive.neutral[200]}`,
  medium: `1px solid ${primitive.neutral[300]}`,
  brand: `1px solid ${primitive.brand[200]}`,
  error: `1.5px solid ${primitive.red[600]}`,
} as const

export const transition = {
  fast: '120ms cubic-bezier(0.4, 0, 0.2, 1)',
  base: '200ms cubic-bezier(0.4, 0, 0.2, 1)',
  smooth: '300ms cubic-bezier(0.4, 0, 0.2, 1)',
  spring: '400ms cubic-bezier(0.34, 1.56, 0.64, 1)',
} as const

export const animation = {
  duration: { fast: '150ms', base: '200ms', slow: '300ms', slower: '400ms' },
  easing: {
    in: 'cubic-bezier(0.4, 0, 1, 1)',
    out: 'cubic-bezier(0, 0, 0.2, 1)',
    inOut: 'cubic-bezier(0.4, 0, 0.2, 1)',
    spring: 'cubic-bezier(0.34, 1.56, 0.64, 1)',
  },
  /** passo de escalonamento entre itens em entradas de lista/grid (stagger) */
  stagger: '40ms',
} as const

export const zIndex = {
  base: 0,
  raised: 10,
  sticky: 100,
  header: 200,
  tabBar: 200,
  drawer: 900,
  overlay: 1000,
  modal: 1100,
  toast: 1200,
} as const

export const breakpoint = { xs: '360px', sm: '768px', md: '1024px', lg: '1280px', xl: '1920px' } as const

export const layout = { headerH: '64px', moduleBarH: '48px', tabBarH: '64px', gutter: '16px' } as const

// paleta categórica para gráficos SVG próprios
export const chart = {
  revenue: '#059669',
  expense: '#dc2626',
  finance: '#2563eb',
  grid: primitive.neutral[200],
  axis: primitive.neutral[400],
  series: ['#059669', '#2563eb', '#f59e0b', '#7c3aed', '#0891b2', '#dc2626', '#14532d', '#9ca3af'],
} as const

/* ------------------------------------------------------------------ *
 * 4. COMPONENTE
 * ------------------------------------------------------------------ */

export const component = {
  // spec §2.6 — cards de dashboard escuros colorizados por categoria
  dashboardTile: {
    revenue: '#1b4332', // receitas/financeiro positivo
    expense: primitive.red[900], // despesas (#7f1d1d)
    finance: '#1e3a5f', // financeiro geral
    production: '#14532d', // produtivo/reprodutivo
    dark: '#1c1917', // neutro/genérico
  },
  login: {
    /** véu em gradiente sobre a arte de fundo integral — escurece só o topo (céu claro)
     *  para o bloco branco da marca; a base da arte já é escura e dispensa véu */
    heroScrim: {
      from: 'rgba(9,41,26,0.72)',
      mid: 'rgba(6,78,59,0.22)',
      to: 'rgba(6,95,70,0)',
    },
  },
  // New-UI — hub agregador do superapp (módulo Início) com Banking central
  hub: {
    /** cartão de saldo premium: gradiente institucional profundo + glow da marca */
    bankCard: {
      from: '#064e3b',
      to: '#022c22',
      glow: 'rgba(74,222,128,0.20)',
      divider: 'rgba(255,255,255,0.14)',
      fgMuted: 'rgba(255,255,255,0.72)',
      skeleton: 'rgba(255,255,255,0.16)',
    },
    /** superfícies glass sutis para destaques sobre o canvas */
    glass: {
      light: 'rgba(255,255,255,0.70)',
      dark: 'rgba(14,42,29,0.55)',
      border: 'rgba(255,255,255,0.16)',
    },
    glassBlur: '14px',
  },
  /** menu "reveal" global (aba Mais/Menu): app encolhe à esquerda, menu escuro desliza da direita */
  revealMenu: {
    appScale: 0.78,
    appShiftX: '-58%',
    menuWidth: '78%',
    bg: '#0b2e1e', // verde floresta profundo — lê como verde, não preto (gbMode segue padrão)
    itemStagger: '30ms',
  },
  /** header global do Shell (premium clean): gradiente verde profundo + decoração de onda */
  header: {
    from: '#09291a',
    mid: '#064e3b',
    to: '#0b5c47',
    tabsBg: '#065f46',
    wave: 'rgba(134,239,172,0.08)',
    /** pílulas de contexto dentro do header (fazenda ativa, crédito) */
    pillBg: 'rgba(255,255,255,0.09)',
    pillBorder: 'rgba(255,255,255,0.16)',
    creditBg: 'rgba(74,222,128,0.10)',
    creditBorder: 'rgba(74,222,128,0.25)',
  },
  /** fundo levemente tintado para KPIs em cards claros */
  kpi: {
    bg: '#f8fffe',
  },
} as const

/* ------------------------------------------------------------------ *
 * EXPORT
 * ------------------------------------------------------------------ */

export const t = {
  color,
  font,
  space,
  size,
  radius,
  shadow,
  border,
  transition,
  animation,
  zIndex,
  breakpoint,
  layout,
  chart,
  component,
  themePalette,
} as const

export type Tokens = typeof t
export default t
