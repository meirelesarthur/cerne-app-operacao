import { useNavigate } from 'react-router-dom'
import { MODULES } from '@/shell/moduleConfig'
import { cn } from '@/lib/cn'

/**
 * Barra de Módulos / module switcher (Nova UI): chips-pílula roláveis sobre o
 * canvas — a ativa é a cápsula ink com texto verde vibrante (tabs segmentadas
 * da referência). Trocar de módulo é navegação de nível Shell.
 */
export function ModuleSwitcher({ activeId }: { activeId: string }) {
  const navigate = useNavigate()

  return (
    <nav className="no-scrollbar flex gap-2 overflow-x-auto bg-canvas px-4 py-3" aria-label="Módulos">
      {MODULES.map((m) => {
        const active = m.id === activeId
        return (
          <button
            key={m.id}
            onClick={() => navigate(m.homeRoute)}
            className={cn(
              'whitespace-nowrap rounded-full px-4 py-2 text-sm font-semibold transition-all active:scale-[0.97]',
              active ? 'bg-ink text-cta' : 'bg-surface text-fg-muted shadow-card hover:text-fg',
            )}
            aria-current={active ? 'page' : undefined}
          >
            {m.label}
          </button>
        )
      })}
    </nav>
  )
}
