import { useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { MODULES } from '@/shell/moduleConfig'
import { t } from '@/design/tokens'
import { cn } from '@/lib/cn'

const tb = t.component.tabbar

/**
 * Dock de módulos (Nova UI): a cápsula flutuante do rodapé troca de MÓDULO —
 * o ativo expande em pílula ink com ícone + rótulo verde vibrante; os demais
 * ficam como círculos icon-only (title + aria-label preservam usabilidade).
 * A faixa interna rola horizontalmente e centraliza o módulo ativo, então a
 * cápsula nunca estoura viewports estreitos. A navegação interna do módulo
 * vive no topo (ContextTabs).
 */
export function BottomTabBar({ activeId }: { activeId: string }) {
  const navigate = useNavigate()
  const activeRef = useRef<HTMLButtonElement | null>(null)

  // mantém o módulo ativo visível/centralizado dentro da cápsula rolável
  useEffect(() => {
    activeRef.current?.scrollIntoView({ inline: 'center', block: 'nearest', behavior: 'smooth' })
  }, [activeId])

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
        className="pointer-events-auto max-w-full rounded-full border border-nav-border bg-nav-bg p-2 shadow-modal"
        style={{ backdropFilter: `blur(${tb.blur})`, WebkitBackdropFilter: `blur(${tb.blur})` }}
      >
        <div className="no-scrollbar flex items-center gap-1 overflow-x-auto rounded-full">
          {MODULES.map((m) => {
            const active = m.id === activeId
            const Icon = m.icon

            return (
              <button
                key={m.id}
                ref={active ? activeRef : undefined}
                onClick={() => navigate(m.homeRoute)}
                aria-current={active ? 'page' : undefined}
                aria-label={m.label}
                title={m.label}
                className={cn(
                  'flex h-12 shrink-0 items-center justify-center rounded-full transition-all active:scale-95',
                  active
                    ? 'gap-2 bg-ink px-4 text-nav-active'
                    : 'w-12 text-nav-fg hover:bg-black/5 dark:hover:bg-white/10',
                )}
              >
                <Icon size={20} strokeWidth={active ? 2.2 : 1.9} aria-hidden="true" />
                {active && <span className="whitespace-nowrap text-sm font-semibold">{m.label}</span>}
              </button>
            )
          })}
        </div>
      </div>
    </nav>
  )
}
