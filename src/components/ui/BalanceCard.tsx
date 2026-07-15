import type { ReactNode } from 'react'
import { Eye, EyeOff, Landmark } from 'lucide-react'
import { t } from '@/design/tokens'
import { cn } from '@/lib/cn'

export interface BalanceCardProps {
  /** rótulo acima do valor (ex.: "Saldo disponível") */
  label?: string
  /** valor monetário já formatado (ex.: "R$ 128.450,32") */
  value: string
  /** identificação da conta (ex.: "Conta GB Bank · Ag 0001") */
  accountLabel?: string
  /** oculta o valor (privacidade em ambientes públicos) */
  hidden?: boolean
  onToggleHidden?: () => void
  /** skeleton elegante enquanto o dado carrega */
  loading?: boolean
  /** slot inferior (ex.: resumo entradas/saídas do mês) */
  footer?: ReactNode
  className?: string
}

const hub = t.component.hub.bankCard

/**
 * Cartão de saldo do Banking (Nova UI): cápsula ink escura nos dois temas —
 * o hero da referência — com glow da marca, números tabulares e toggle de
 * visibilidade com touch target de 44px. Skeleton interno preserva o layout.
 */
export function BalanceCard({
  label = 'Saldo disponível',
  value,
  accountLabel,
  hidden = false,
  onToggleHidden,
  loading = false,
  footer,
  className,
}: BalanceCardProps) {
  return (
    <section
      aria-label={label}
      className={cn('relative overflow-hidden rounded-3xl bg-ink p-5 text-ink-fg shadow-card', className)}
    >
      {/* glow radial sutil da marca — profundidade sem ruído */}
      <div
        aria-hidden="true"
        className="pointer-events-none absolute -right-10 -top-16 h-44 w-44 rounded-full"
        style={{ background: `radial-gradient(circle, ${hub.glow} 0%, transparent 70%)` }}
      />

      <div className="relative flex items-start justify-between">
        <div className="flex items-center gap-2.5">
          <span className="flex h-10 w-10 items-center justify-center rounded-full bg-ink-bubble">
            <Landmark size={17} aria-hidden="true" />
          </span>
          <div>
            <p className="text-sm font-medium text-ink-muted">{label}</p>
            {accountLabel && <p className="text-xs text-ink-subtle">{accountLabel}</p>}
          </div>
        </div>

        {onToggleHidden && (
          <button
            type="button"
            onClick={onToggleHidden}
            aria-label={hidden ? 'Mostrar saldo' : 'Ocultar saldo'}
            aria-pressed={hidden}
            className="flex h-11 w-11 items-center justify-center rounded-full transition-colors hover:bg-ink-bubble active:bg-white/15"
          >
            {hidden ? <EyeOff size={20} /> : <Eye size={20} />}
          </button>
        )}
      </div>

      <div className="relative mt-4 min-h-[40px]">
        {loading ? (
          <div className="h-9 w-2/3 animate-pulse rounded-full bg-ink-bubble" aria-hidden="true" />
        ) : (
          <p className="text-4xl font-bold leading-tight tabular-nums tracking-tight">
            {hidden ? '••••••' : value}
          </p>
        )}
      </div>

      {footer && <div className="relative mt-4 border-t border-ink-line pt-3">{footer}</div>}
    </section>
  )
}

/** Coluna de resumo para o footer do BalanceCard (ex.: entradas/saídas do mês). */
export function BalanceSummaryItem({
  icon,
  label,
  value,
  hidden = false,
}: {
  icon?: ReactNode
  label: string
  value: string
  hidden?: boolean
}) {
  return (
    <div className="flex items-center gap-2">
      {icon && (
        <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-ink-bubble">{icon}</span>
      )}
      <div className="min-w-0">
        <p className="text-xs text-ink-muted">{label}</p>
        <p className="truncate text-sm font-semibold tabular-nums">{hidden ? '••••' : value}</p>
      </div>
    </div>
  )
}
