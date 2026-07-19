import { useNavigate } from 'react-router-dom'
import { MODULES } from '@/shell/moduleConfig'
import { t } from '@/design/tokens'
import { cn } from '@/lib/cn'

const tb = t.component.tabbar

/**
 * Dock de módulos (Nova UI): cápsula flutuante icon-only como na referência —
 * os 6 módulos sempre visíveis (sem rolagem nem corte em viewports estreitos),
 * o ativo vira círculo ink com ícone verde vibrante. `title` + aria-label
 * preservam a identificação; a navegação interna do módulo vive no topo
 * (ContextTabs), que também nomeia o contexto atual.
 */
export function BottomTabBar({ activeId }: { activeId: string }) {
  const navigate = useNavigate()

  return (
    <nav
      className="pointer-events-none absolute inset-x-0 bottom-0 flex justify-center"
      style={{
        zIndex: t.zIndex.tabBar,
        paddingBottom: `calc(${tb.inset} + env(safe-area-inset-bottom))`,
        paddingLeft: tb.inset,
        paddingRight: tb.inset,
      }}
      aria-label="Módulos do superapp"
    >
      <div
        className="pointer-events-auto flex max-w-full items-center gap-1 rounded-full border border-nav-border bg-nav-bg p-2 shadow-modal"
        style={{ backdropFilter: `blur(${tb.blur})`, WebkitBackdropFilter: `blur(${tb.blur})` }}
      >
        {MODULES.map((m) => {
          const active = m.id === activeId
          const Icon = m.icon

          return (
            <button
              key={m.id}
              onClick={() => navigate(m.homeRoute)}
              aria-current={active ? 'page' : undefined}
              aria-label={m.label}
              title={m.label}
              className={cn(
                'flex h-12 w-12 shrink-0 items-center justify-center rounded-full transition-all active:scale-95',
                active ? 'bg-ink text-nav-active' : 'text-nav-fg hover:bg-black/5 dark:hover:bg-white/10',
              )}
            >
              <Icon size={20} strokeWidth={active ? 2.2 : 1.9} aria-hidden="true" />
            </button>
          )
        })}
      </div>
    </nav>
  )
}
