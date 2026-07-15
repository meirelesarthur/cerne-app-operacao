import type { ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { Bell, ChevronRight, Eye } from 'lucide-react'
import { IconButton } from '@/components/ui/IconButton'
import { useShellStore } from '@/shell/state/shellStore'
import { t } from '@/design/tokens'
import { cn } from '@/lib/cn'

export interface ShellHeaderProps {
  /** Callback do ícone "olho" (modo consulta) — contextual ao módulo ativo (spec §3.3/§6.1). */
  onConsultMode?: () => void
  consultActive?: boolean
  /** slot de contexto do módulo ativo (pílulas: fazenda, crédito…) dentro do gradiente */
  children?: ReactNode
}

/**
 * Header global do Shell (premium clean): gradiente verde profundo com onda
 * decorativa, saudação grande, controles circulares outline e slot de
 * contexto do módulo (pílulas). Persiste ao trocar de módulo.
 */
export function ShellHeader({ onConsultMode, consultActive, children }: ShellHeaderProps) {
  const navigate = useNavigate()
  const user = useShellStore((s) => s.user)
  const unread = useShellStore((s) => s.notifications.filter((n) => !n.read).length)

  const hour = 8 // determinístico no protótipo (sem Date.now)
  const greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite'

  return (
    <header
      className="relative mb-[-18px] overflow-hidden px-4 pb-10 pt-4"
      style={{
        background: `linear-gradient(170deg, ${t.component.header.from} 0%, ${t.component.header.mid} 52%, ${t.component.header.to} 100%)`,
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
        <path d="M210 80V20C170 45 120 55 80 40C50 29 25 34 0 55V80H210Z" fill={t.component.header.wave} />
        <path
          d="M210 80V45C180 60 145 62 115 50C85 38 60 42 30 60C18 67 8 72 0 74V80H210Z"
          fill={t.component.header.wave}
        />
      </svg>

      <div className="relative flex items-start gap-3">
        <button
          className="flex flex-1 items-center gap-1 text-left"
          onClick={() => navigate('/perfil')}
          aria-label="Abrir perfil"
        >
          <div>
            <p className="text-lg font-normal text-white/60">{greeting},</p>
            <p className="flex items-center gap-1.5 text-3xl font-bold leading-tight tracking-tight text-white">
              {user.name}
              <ChevronRight size={18} className="text-white/50" strokeWidth={2.5} />
            </p>
          </div>
        </button>

        <div className="flex gap-2 pt-1">
          {onConsultMode && (
            <IconButton
              label={consultActive ? 'Sair do modo consulta' : 'Modo consulta'}
              variant="onDark"
              onClick={onConsultMode}
              className={cn(consultActive && 'bg-white/20')}
            >
              <Eye size={18} />
            </IconButton>
          )}

          <div className="relative">
            <IconButton label="Notificações" variant="onDark" onClick={() => navigate('/notificacoes')}>
              <Bell size={18} />
            </IconButton>
            {unread > 0 && (
              <span
                aria-hidden="true"
                className="absolute right-2 top-2 h-2 w-2 rounded-full bg-amber-500"
                style={{ border: `1.5px solid ${t.component.header.mid}` }}
              />
            )}
          </div>
        </div>
      </div>

      {children && <div className="relative mt-3 flex flex-col items-start gap-2">{children}</div>}
    </header>
  )
}
