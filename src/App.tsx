import { ThemeProvider } from './context/ThemeContext'

/**
 * App raiz. Na Fase 0 exibe apenas um smoke test da fundação (tokens + tema).
 * Substituído na Fase 1 pelo RouterProvider com o Shell.
 */
export function App() {
  return (
    <ThemeProvider>
      <div className="flex min-h-full items-center justify-center bg-canvas p-6">
        <div className="w-full max-w-phone rounded-2xl bg-surface p-6 shadow-card">
          <h1 className="text-2xl font-bold text-fg">GB CERNE</h1>
          <p className="mt-1 text-md text-fg-muted">Fundação carregada — tokens, tema e componentes base.</p>
        </div>
      </div>
    </ThemeProvider>
  )
}
