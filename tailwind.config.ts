import type { Config } from 'tailwindcss'
import { primitive, font, space, radius, shadow, animation } from './src/design/tokens'

/**
 * Tailwind derivado de src/design/tokens.ts (Lei 3).
 * Não hardcode valores aqui — importe dos tokens.
 * gbMode (tema escuro) é ativado via data-theme="gbMode" na raiz.
 */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  darkMode: ['selector', '[data-theme="gbMode"]'],
  theme: {
    extend: {
      colors: {
        brand: primitive.brand,
        neutral: primitive.neutral,
        red: primitive.red,
        amber: primitive.amber,
        blue: primitive.blue,
        // papéis theme-aware expostos como CSS vars (definidas em tokens.css)
        canvas: 'var(--bg-canvas)',
        surface: 'var(--bg-surface)',
        'surface-subtle': 'var(--bg-subtle)',
        fg: 'var(--fg-default)',
        'fg-muted': 'var(--fg-muted)',
        'fg-subtle': 'var(--fg-subtle)',
        'border-default': 'var(--border-default)',
        'border-tint': 'var(--border-tint)',
        kpi: 'var(--bg-kpi)',
        accent: 'var(--accent-default)',
        'accent-hover': 'var(--accent-hover)',
        'accent-subtle': 'var(--accent-subtle)',
        // Nova UI — superfície ink (hero escuro nos dois temas), CTA vibrante e tab bar
        ink: 'var(--ink-bg)',
        'ink-fg': 'var(--ink-fg)',
        'ink-muted': 'var(--ink-muted)',
        'ink-subtle': 'var(--ink-subtle)',
        'ink-bubble': 'var(--ink-bubble)',
        'ink-line': 'var(--ink-line)',
        cta: 'var(--cta-bg)',
        'cta-hover': 'var(--cta-hover)',
        'cta-fg': 'var(--cta-fg)',
        'nav-bg': 'var(--nav-bg)',
        'nav-fg': 'var(--nav-fg)',
        'nav-active': 'var(--nav-active)',
        'nav-border': 'var(--nav-border)',
      },
      fontFamily: { sans: ['Outfit', 'sans-serif'] },
      fontSize: font.size,
      fontWeight: {
        normal: String(font.weight.normal),
        medium: String(font.weight.medium),
        semibold: String(font.weight.semibold),
        bold: String(font.weight.bold),
        extrabold: String(font.weight.extrabold),
      },
      lineHeight: {
        tight: String(font.lineHeight.tight),
        snug: String(font.lineHeight.snug),
        normal: String(font.lineHeight.normal),
        relaxed: String(font.lineHeight.relaxed),
      },
      spacing: space,
      borderRadius: radius,
      boxShadow: {
        card: 'var(--shadow-card)',
        'card-hover': 'var(--shadow-card-hover)',
        modal: 'var(--shadow-modal)',
        brand: shadow.brand,
      },
      maxWidth: { phone: '420px' },
      transitionDuration: {
        spring: animation.duration.slower,
        slow: animation.duration.slow,
      },
      transitionTimingFunction: {
        spring: animation.easing.spring,
        out: animation.easing.out,
      },
      keyframes: {
        rise: {
          from: { opacity: '0', transform: `translateY(${space[3]})` },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
      },
      animation: {
        // entrada de seções/cards (ease-out, interruptível, 60fps: transform+opacity)
        rise: `rise ${animation.duration.slow} ${animation.easing.out} both`,
      },
    },
  },
  plugins: [],
} satisfies Config
