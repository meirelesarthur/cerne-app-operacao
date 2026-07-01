import { useNavigate } from 'react-router-dom'
import { MODULES } from '@/shell/moduleConfig'
import { cn } from '@/lib/cn'

/**
 * Barra de Módulos / module switcher (spec §6.2): linha horizontal com scroll,
 * item ativo com sublinhado verde. Trocar de módulo é navegação de nível Shell.
 */
export function ModuleSwitcher({ activeId }: { activeId: string }) {
  const navigate = useNavigate()

  return (
    <nav
      className="no-scrollbar flex gap-1 overflow-x-auto px-2"
      style={{ background: 'var(--nav-bg)' }}
      aria-label="Módulos"
    >
      {MODULES.map((m) => {
        const active = m.id === activeId
        return (
          <button
            key={m.id}
            onClick={() => navigate(m.homeRoute)}
            className={cn(
              'relative whitespace-nowrap px-3 py-2.5 text-md font-semibold transition-colors',
              active ? 'text-white' : 'text-white/55 hover:text-white/80',
            )}
            aria-current={active ? 'page' : undefined}
          >
            {m.label}
            {active && <span className="absolute inset-x-3 bottom-0 h-0.5 rounded-full bg-[var(--nav-active)]" />}
          </button>
        )
      })}
    </nav>
  )
}
