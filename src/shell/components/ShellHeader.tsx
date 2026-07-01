import { useNavigate } from 'react-router-dom'
import { Bell, ChevronDown, Eye } from 'lucide-react'
import { IconButton } from '@/components/ui/IconButton'
import { Badge } from '@/components/ui/Badge'
import { useShellStore } from '@/shell/state/shellStore'
import { cn } from '@/lib/cn'

export interface ShellHeaderProps {
  /** Callback do ícone "olho" (modo consulta) — contextual ao módulo ativo (spec §3.3/§6.1). */
  onConsultMode?: () => void
  consultActive?: boolean
}

/**
 * Header global do Shell (spec §6.1): fundo verde escuro, saudação, sino e ícone "olho".
 * Persiste ao trocar de módulo — só o conteúdo abaixo muda.
 */
export function ShellHeader({ onConsultMode, consultActive }: ShellHeaderProps) {
  const navigate = useNavigate()
  const user = useShellStore((s) => s.user)
  const unread = useShellStore((s) => s.notifications.filter((n) => !n.read).length)

  const hour = 8 // determinístico no protótipo (sem Date.now)
  const greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite'

  return (
    <header className="flex items-center gap-3 px-4 pb-3 pt-4" style={{ background: 'var(--nav-bg)' }}>
      <button
        className="flex flex-1 items-center gap-1 text-left"
        onClick={() => navigate('/perfil')}
        aria-label="Abrir perfil"
      >
        <div>
          <p className="text-xs font-medium text-white/70">{greeting},</p>
          <p className="flex items-center gap-1 text-lg font-bold text-white">
            {user.name}
            <ChevronDown size={16} className="text-white/70" />
          </p>
        </div>
      </button>

      {onConsultMode && (
        <IconButton
          label={consultActive ? 'Sair do modo consulta' : 'Modo consulta'}
          variant="onDark"
          onClick={onConsultMode}
          className={cn(consultActive && 'bg-white/20')}
        >
          <Eye size={20} />
        </IconButton>
      )}

      <div className="relative">
        <IconButton label="Notificações" variant="onDark" onClick={() => navigate('/notificacoes')}>
          <Bell size={20} />
        </IconButton>
        {unread > 0 && (
          <span className="absolute -right-0.5 -top-0.5">
            <Badge tone="red">{unread}</Badge>
          </span>
        )}
      </div>
    </header>
  )
}
