import { useEffect } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { Bell, Settings, Moon, LogOut, ChevronRight } from 'lucide-react'
import { Avatar } from '@/components/ui/Avatar'
import { MenuItem } from '@/components/ui/MenuItem'
import { Badge } from '@/components/ui/Badge'
import { getMenuSections, type ModuleDef } from '@/shell/moduleConfig'
import { ViewSwitch } from '@/modules/fazendas/components/ViewSwitch'
import { useShellStore } from '@/shell/state/shellStore'
import { useTheme } from '@/context/ThemeContext'
import { t } from '@/design/tokens'
import { cn } from '@/lib/cn'

const rm = t.component.revealMenu

/** delay escalonado de entrada dos itens do menu (motion tokenizado) */
const stagger = (i: number) => ({ animationDelay: `calc(${i} * ${rm.itemStagger})` })

/**
 * Painel do menu "reveal" global (New-UI): revelado à direita enquanto o app
 * encolhe para a esquerda. Contextual ao módulo ativo — lista as demais
 * funcionalidades do módulo (menuSections do moduleConfig, com fallback
 * derivado das bottomTabs) + seção de conta. Fecha em Esc, ao navegar ou
 * ao tocar no app.
 */
export function RevealMenu({ module }: { module: ModuleDef }) {
  const navigate = useNavigate()
  const location = useLocation()
  const menuOpen = useShellStore((s) => s.menuOpen)
  const closeMenu = useShellStore((s) => s.closeMenu)
  const user = useShellStore((s) => s.user)
  const unread = useShellStore((s) => s.notifications.filter((n) => !n.read).length)
  const { isGbMode, toggle } = useTheme()

  // Esc fecha o menu enquanto aberto
  useEffect(() => {
    if (!menuOpen) return
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') closeMenu()
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [menuOpen, closeMenu])

  // trocar de rota fecha o menu (deep links, voltar do navegador)
  useEffect(() => {
    closeMenu()
  }, [location.pathname, closeMenu])

  const go = (route: string) => {
    closeMenu()
    navigate(route)
  }

  const roleLabel = user.role === 'operador' ? 'Operador' : 'Administrador'
  const sections = getMenuSections(module)
  const ModuleIcon = module.icon

  // índice corrido para o stagger atravessar seções de tamanhos variados
  let idx = 0
  const next = () => stagger(idx++)

  return (
    <aside
      role={menuOpen ? 'dialog' : undefined}
      aria-modal={menuOpen || undefined}
      aria-label={`Menu do módulo ${module.label}`}
      aria-hidden={!menuOpen}
      className={cn(
        'no-scrollbar absolute inset-y-0 right-0 flex flex-col gap-1 overflow-y-auto px-4 py-6',
        'transition-[opacity,transform] duration-spring ease-spring motion-reduce:transition-none',
        menuOpen ? 'translate-x-0 opacity-100' : 'pointer-events-none translate-x-8 opacity-0',
      )}
      style={{ width: rm.menuWidth }}
    >
      {menuOpen && (
        <>
          {/* identidade do usuário */}
          <button
            type="button"
            onClick={() => go('/perfil')}
            className="animate-rise mb-3 flex w-full items-center gap-3 rounded-2xl p-2 text-left transition-colors hover:bg-white/10"
            style={next()}
          >
            <Avatar name={user.name} initials={user.initials} size="lg" />
            <span className="min-w-0 flex-1">
              <span className="block truncate text-lg font-bold text-white">{user.name}</span>
              <span className="block text-xs text-white/55">{roleLabel} · GB CERNE</span>
            </span>
            <ChevronRight size={18} className="shrink-0 text-white/40" aria-hidden="true" />
          </button>

          {/* contexto do módulo ativo */}
          <div className="animate-rise mb-2 flex items-center gap-2 px-3" style={next()}>
            <span className="flex h-7 w-7 items-center justify-center rounded-lg bg-white/10 text-white/80">
              <ModuleIcon size={15} aria-hidden="true" />
            </span>
            <span className="text-sm font-semibold text-white/80">{module.label}</span>
          </div>

          {/* switch de visão do Fazendas (Gerencial ⇄ Campo) — saiu da tela para o menu */}
          {module.id === 'fazendas' && (
            <div className="animate-rise mb-2 px-3" style={next()}>
              <p className="pb-1.5 text-xs font-semibold uppercase tracking-wide text-white/40">Visão</p>
              <ViewSwitch onChange={closeMenu} />
            </div>
          )}

          {/* funcionalidades do módulo atual */}
          {sections.map((section) => (
            <div key={section.title} className="contents">
              <p className="animate-rise px-3 pb-1 pt-2 text-xs font-semibold uppercase tracking-wide text-white/40" style={next()}>
                {section.title}
              </p>
              {section.items.map((item) => (
                <div key={item.id} className="animate-rise" style={next()}>
                  <MenuItem
                    variant="onDark"
                    icon={item.icon}
                    label={item.label}
                    active={location.pathname === item.route}
                    onClick={() => go(item.route)}
                  />
                </div>
              ))}
            </div>
          ))}

          <div className="animate-rise my-3 border-t border-white/10" style={next()} aria-hidden="true" />

          {/* conta e preferências */}
          <p className="animate-rise px-3 pb-1 text-xs font-semibold uppercase tracking-wide text-white/40" style={next()}>
            Conta
          </p>
          <div className="animate-rise" style={next()}>
            <MenuItem
              variant="onDark"
              icon={Bell}
              label="Notificações"
              trailing={unread > 0 ? <Badge tone="red">{unread}</Badge> : undefined}
              onClick={() => go('/notificacoes')}
            />
          </div>
          <div className="animate-rise" style={next()}>
            <MenuItem variant="onDark" icon={Settings} label="Configurações" onClick={() => go('/perfil')} />
          </div>
          <div className="animate-rise" style={next()}>
            <MenuItem
              variant="onDark"
              icon={Moon}
              label="Modo GB"
              description="Tema escuro para campo e baixa luz"
              trailing={<span className="text-xs font-semibold text-white/70">{isGbMode ? 'Ativo' : 'Inativo'}</span>}
              onClick={toggle}
            />
          </div>

          <div className="mt-auto pt-4">
            <div className="animate-rise" style={next()}>
              <MenuItem variant="onDark" tone="danger" icon={LogOut} label="Sair" onClick={() => go('/login')} />
            </div>
          </div>
        </>
      )}
    </aside>
  )
}
