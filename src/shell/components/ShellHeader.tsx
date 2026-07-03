import { useNavigate } from 'react-router-dom'
import { Bell, ChevronDown, Eye } from 'lucide-react'
import { IconButton } from '@/components/ui/IconButton'
import { Badge } from '@/components/ui/Badge'
import { useShellStore } from '@/shell/state/shellStore'
import { t } from '@/design/tokens'
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
    <header
      className="relative flex items-center gap-3 overflow-hidden px-4 pb-3 pt-4"
      style={{
        background: `linear-gradient(155deg, ${t.component.header.from} 0%, ${t.component.header.mid} 52%, ${t.component.header.to} 100%)`,
      }}
    >
      <svg
        aria-hidden="true"
        className="pointer-events-none absolute bottom-0 right-0"
        width="210"
        height="80"
        viewBox="0 0 210 80"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          d="M210 80V20C170 45 120 55 80 40C50 29 25 34 0 55V80H210Z"
          fill={t.component.header.wave}
        />
        <path
          d="M210 80V45C180 60 145 62 115 50C85 38 60 42 30 60C18 67 8 72 0 74V80H210Z"
          fill={t.component.header.wave}
        />
      </svg>

      <button
        className="relative flex flex-1 items-center gap-1 text-left"
        onClick={() => navigate('/perfil')}
        aria-label="Abrir perfil"
      >
        <div>
          <p className="text-xs font-medium text-white/70">{greeting},</p>
          <p className="flex items-center gap-1 text-2xl font-bold tracking-tight text-white">
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
          className={cn('relative', consultActive && 'bg-white/20')}
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
