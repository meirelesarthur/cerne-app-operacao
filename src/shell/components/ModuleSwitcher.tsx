import { useNavigate } from 'react-router-dom'
import { MODULES } from '@/shell/moduleConfig'
import { t } from '@/design/tokens'
import { cn } from '@/lib/cn'

/**
 * Barra de Módulos / module switcher (spec §6.2): linha horizontal com scroll,
 * item ativo com sublinhado verde. Trocar de módulo é navegação de nível Shell.
 * `relative` é obrigatório: a barra sobrepõe o header (mb negativo) e precisa
 * pintar sobre ele para os cantos superiores arredondados aparecerem.
 */
export function ModuleSwitcher({ activeId }: { activeId: string }) {
  const navigate = useNavigate()

  return (
    <nav
      className="no-scrollbar relative flex gap-1 overflow-x-auto rounded-t-2xl px-2"
      style={{ background: t.component.header.tabsBg }}
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
              active ? 'text-white' : 'text-white/45 hover:text-white/80',
            )}
            aria-current={active ? 'page' : undefined}
          >
            {m.label}
            {active && <span className="absolute inset-x-0 bottom-0 h-[3px] rounded-t-full bg-[var(--nav-active)]" />}
          </button>
        )
      })}
    </nav>
  )
}
