import { useLocation, useNavigate } from 'react-router-dom'
import type { ModuleDef } from '@/shell/moduleConfig'
import { cn } from '@/lib/cn'

/**
 * Bottom Tab Bar genérico (spec §6.8): recebe os itens do módulo ativo via `moduleConfig`.
 * Não há itens hardcodados — cada módulo injeta seu próprio conjunto.
 */
export function BottomTabBar({ module }: { module: ModuleDef }) {
  const navigate = useNavigate()
  const location = useLocation()

  // sub-path atual dentro do módulo (ex.: /fazendas/atividades → "atividades")
  const rest = location.pathname.replace(new RegExp(`^/${module.id}/?`), '')
  const activePath = rest.split('/')[0] ?? ''

  return (
    <nav
      className="flex items-stretch border-t border-border-default bg-surface pb-[env(safe-area-inset-bottom)]"
      style={{ height: 'var(--tab-h, 64px)' }}
      aria-label={`Navegação do módulo ${module.label}`}
    >
      {module.bottomTabs.map((tab) => {
        const active = tab.path === activePath
        const Icon = tab.icon
        const target = tab.path ? `/${module.id}/${tab.path}` : `/${module.id}`

        if (tab.elevated) {
          return (
            <button
              key={tab.id}
              onClick={() => navigate(target)}
              className="flex flex-1 flex-col items-center justify-center gap-0.5"
              aria-current={active ? 'page' : undefined}
            >
              <span className="-mt-6 flex h-12 w-12 items-center justify-center rounded-full bg-accent text-white shadow-brand">
                <Icon size={22} />
              </span>
              <span className="text-[10px] font-semibold text-accent">{tab.label}</span>
            </button>
          )
        }

        return (
          <button
            key={tab.id}
            onClick={() => navigate(target)}
            className={cn(
              'flex flex-1 flex-col items-center justify-center gap-1 transition-colors',
              active ? 'text-accent' : 'text-fg-subtle hover:text-fg-muted',
            )}
            aria-current={active ? 'page' : undefined}
          >
            <Icon size={22} strokeWidth={active ? 2.4 : 1.8} />
            <span className="text-[10px] font-semibold leading-none">{tab.label}</span>
          </button>
        )
      })}
    </nav>
  )
}
