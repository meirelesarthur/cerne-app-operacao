import type { ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { Bell, Eye, Menu } from 'lucide-react'
import { Avatar } from '@/components/ui/Avatar'
import { IconButton } from '@/components/ui/IconButton'
import { Pressable } from '@/components/ui/Pressable'
import { useShellStore } from '@/shell/state/shellStore'
import { cn } from '@/lib/cn'

export interface ShellHeaderProps {
  /** Callback do ícone "olho" (modo consulta) — contextual ao módulo ativo (spec §3.3/§6.1). */
  onConsultMode?: () => void
  consultActive?: boolean
  /** slot de contexto do módulo ativo (pílulas: fazenda, crédito…) */
  children?: ReactNode
}

/**
 * Header global do Shell (Nova UI): zona clara sobre o canvas — avatar + saudação
 * à esquerda, bolhas de ação circulares à direita (referência). Persiste ao
 * trocar de módulo; o contraste vem do conteúdo (hero ink), não do header.
 */
export function ShellHeader({ onConsultMode, consultActive, children }: ShellHeaderProps) {
  const navigate = useNavigate()
  const user = useShellStore((s) => s.user)
  const unread = useShellStore((s) => s.notifications.filter((n) => !n.read).length)
  const menuOpen = useShellStore((s) => s.menuOpen)
  const openMenu = useShellStore((s) => s.openMenu)

  const hour = 8 // determinístico no protótipo (sem Date.now)
  const greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite'

  return (
    <header className="bg-canvas px-4 pb-1 pt-4">
      <div className="flex items-center gap-3">
        <Pressable
          className="flex min-w-0 flex-1 items-center gap-3 text-left"
          onClick={() => navigate('/perfil')}
          aria-label="Abrir perfil"
        >
          <Avatar name={user.name} initials={user.initials} size="lg" className="h-12 w-12 text-md" />
          <div className="min-w-0">
            <p className="text-sm font-medium leading-tight text-fg-muted">{greeting},</p>
            <p className="truncate text-xl font-bold leading-tight tracking-tight text-fg">{user.name}</p>
          </div>
        </Pressable>

        <div className="flex shrink-0 gap-2">
          {onConsultMode && (
            <IconButton
              label={consultActive ? 'Sair do modo consulta' : 'Modo consulta'}
              variant="solid"
              size="lg"
              onClick={onConsultMode}
              className={cn(consultActive && 'bg-ink text-ink-fg hover:bg-ink')}
            >
              <Eye size={19} />
            </IconButton>
          )}

          <div className="relative">
            <IconButton label="Notificações" variant="solid" size="lg" onClick={() => navigate('/notificacoes')}>
              <Bell size={19} />
            </IconButton>
            {unread > 0 && (
              <span
                aria-hidden="true"
                className="absolute right-3 top-2.5 h-2 w-2 rounded-full bg-red-500 ring-2 ring-surface"
              />
            )}
          </div>

          {/* "Mais" do módulo — abre o RevealMenu global (antes vivia no rodapé) */}
          <IconButton
            label="Mais"
            variant="solid"
            size="lg"
            onClick={openMenu}
            aria-haspopup="dialog"
            aria-expanded={menuOpen}
            className={cn(menuOpen && 'bg-ink text-ink-fg hover:bg-ink')}
          >
            <Menu size={19} />
          </IconButton>
        </div>
      </div>

      {children && <div className="mt-3 flex flex-col items-start gap-2">{children}</div>}
    </header>
  )
}
