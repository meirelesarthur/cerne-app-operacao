import { createContext, useCallback, useContext, useEffect, useState, type ReactNode } from 'react'
import { themePalette, type ThemePalette } from '@/design/tokens'

export type ThemeMode = 'light' | 'gbMode'

interface ThemeContextValue {
  mode: ThemeMode
  colors: ThemePalette
  isGbMode: boolean
  toggle: () => void
  setMode: (mode: ThemeMode) => void
}

const ThemeContext = createContext<ThemeContextValue | null>(null)

export function ThemeProvider({ children, initial = 'light' }: { children: ReactNode; initial?: ThemeMode }) {
  const [mode, setMode] = useState<ThemeMode>(initial)

  // Aplica o tema na raiz do documento — dispara a troca das CSS vars (tokens.css).
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', mode)
  }, [mode])

  const toggle = useCallback(() => setMode((m) => (m === 'light' ? 'gbMode' : 'light')), [])

  return (
    <ThemeContext.Provider value={{ mode, colors: themePalette[mode], isGbMode: mode === 'gbMode', toggle, setMode }}>
      {children}
    </ThemeContext.Provider>
  )
}

// eslint-disable-next-line react-refresh/only-export-components
export function useTheme(): ThemeContextValue {
  const ctx = useContext(ThemeContext)
  if (!ctx) throw new Error('useTheme deve ser usado dentro de <ThemeProvider>')
  return ctx
}
