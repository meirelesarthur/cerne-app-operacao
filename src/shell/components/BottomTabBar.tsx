import { useLocation, useNavigate } from 'react-router-dom'
import type { ModuleDef } from '@/shell/moduleConfig'
import { useShellStore } from '@/shell/state/shellStore'
import { t } from '@/design/tokens'
import { cn } from '@/lib/cn'

const tb = t.component.tabbar

/**
 * Bottom Tab Bar (Nova UI): cápsula flutuante translúcida com botões circulares,
 * como na referência — a aba ativa vira um círculo ink com ícone verde vibrante.
 * Recebe os itens do módulo ativo via `moduleConfig`; nenhum item é hardcodado.
 * Ícone-only com `title` + aria-label (usabilidade preservada).
 */
export function BottomTabBar({ module }: { module: ModuleDef }) {
  const navigate = useNavigate()
  const location = useLocation()
  const menuOpen = useShellStore((s) => s.menuOpen)
  const openMenu = useShellStore((s) => s.openMenu)

  // sub-path atual dentro do módulo (ex.: /fazendas/atividades → "atividades")
  const rest = location.pathname.replace(new RegExp(`^/${module.id}/?`), '')
  const activePath = rest.split('/')[0] ?? ''

  const itemBase = 'flex h-12 w-12 items-center justify-center rounded-full transition-all active:scale-95'
  const itemIdle = 'text-nav-fg hover:bg-black/5 dark:hover:bg-white/10'
  const itemActive = 'bg-ink text-nav-active'

  return (
    <nav
      className="pointer-events-none absolute inset-x-0 bottom-0 flex justify-center"
      style={{ zIndex: t.zIndex.tabBar, paddingBottom: `calc(${tb.inset} + env(safe-area-inset-bottom))` }}
      aria-label={`Navegação do módulo ${module.label}`}
    >
      <div
        className="pointer-events-auto flex items-center gap-1.5 rounded-full border border-nav-border bg-nav-bg p-2 shadow-modal"
        style={{ backdropFilter: `blur(${tb.blur})`, WebkitBackdropFilter: `blur(${tb.blur})` }}
      >
        {module.bottomTabs.map((tab) => {
          const active = tab.path === activePath && !tab.action
          const Icon = tab.icon
          const target = tab.path ? `/${module.id}/${tab.path}` : `/${module.id}`

          // aba de ação: abre o RevealMenu global em vez de navegar
          if (tab.action === 'menu') {
            return (
              <button
                key={tab.id}
                onClick={openMenu}
                aria-haspopup="dialog"
                aria-expanded={menuOpen}
                aria-label={tab.label}
                title={tab.label}
                className={cn(itemBase, menuOpen ? itemActive : itemIdle)}
              >
                <Icon size={21} strokeWidth={menuOpen ? 2.2 : 1.9} aria-hidden="true" />
              </button>
            )
          }

          // botão central elevado (ex.: "Registrar" em campo): CTA vibrante
          if (tab.elevated) {
            return (
              <button
                key={tab.id}
                onClick={() => navigate(target)}
                aria-current={active ? 'page' : undefined}
                aria-label={tab.label}
                title={tab.label}
                className={cn(itemBase, 'bg-cta text-cta-fg shadow-brand hover:bg-cta-hover')}
              >
                <Icon size={22} strokeWidth={2.1} aria-hidden="true" />
              </button>
            )
          }

          return (
            <button
              key={tab.id}
              onClick={() => navigate(target)}
              aria-current={active ? 'page' : undefined}
              aria-label={tab.label}
              title={tab.label}
              className={cn(itemBase, active ? itemActive : itemIdle)}
            >
              <Icon size={21} strokeWidth={active ? 2.2 : 1.9} aria-hidden="true" />
            </button>
          )
        })}
      </div>
    </nav>
  )
}
