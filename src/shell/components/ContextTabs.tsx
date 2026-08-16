import { useLocation, useNavigate } from 'react-router-dom'
import type { ModuleDef } from '@/shell/moduleConfig'
import { cn } from '@/lib/cn'
import { useShellStore } from '@/shell/state/shellStore'

/**
 * Abas de contexto do módulo ativo (Nova UI): chips-pílula roláveis no topo —
 * a navegação interna do módulo (antes no rodapé) vive aqui; a ativa é a
 * cápsula ink com texto verde vibrante (tabs segmentadas da referência).
 * A ação "Mais" não entra: ela vira bolha no topo direito do header.
 */
export function ContextTabs({ module }: { module: ModuleDef }) {
  const navigate = useNavigate()
  const location = useLocation()
  const role = useShellStore((s) => s.user.role)

  // sub-path atual dentro do módulo (ex.: /fazendas/atividades → "atividades")
  const rest = location.pathname.replace(new RegExp(`^/${module.id}/?`), '')
  const activePath = rest.split('/')[0] ?? ''

  const tabs = module.bottomTabs.filter((tab) => !tab.action && (!tab.audience || tab.audience.includes(role)))

  return (
    <nav
      className="no-scrollbar flex gap-2 overflow-x-auto bg-canvas px-4 py-3"
      aria-label={`Navegação do módulo ${module.label}`}
    >
      {tabs.map((tab) => {
        const active = tab.path === activePath
        const target = tab.path ? `/${module.id}/${tab.path}` : `/${module.id}`
        return (
          <button
            key={tab.id}
            onClick={() => navigate(target)}
            className={cn(
              'whitespace-nowrap rounded-full px-4 py-2 text-sm font-semibold transition-all active:scale-[0.97]',
              active ? 'bg-ink text-cta' : 'bg-surface text-fg-muted shadow-card hover:text-fg',
            )}
            aria-current={active ? 'page' : undefined}
          >
            {tab.label}
          </button>
        )
      })}
    </nav>
  )
}
