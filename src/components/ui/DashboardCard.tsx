import type { LucideIcon } from 'lucide-react'
import { TrendingUp, TrendingDown, Lock } from 'lucide-react'
import { SparklineArea } from './SparklineArea'
import { t } from '@/design/tokens'
import { cn } from '@/lib/cn'

export type DashboardTileCategory = keyof typeof t.component.dashboardTile

export interface DashboardCardProps {
  icon: LucideIcon
  label: string
  value: string
  /** variação percentual; positivo = verde, negativo = vermelho. */
  delta?: number
  spark?: number[]
  /** claro (padrão do print) ou escuro categorizado (spec §6.6). */
  variant?: 'light' | DashboardTileCategory
  /** estado desativado (ex.: bloco produtivo/reprodutivo, spec §4.1). */
  disabled?: boolean
  disabledLabel?: string
  onClick?: () => void
}

export function DashboardCard({
  icon: Icon,
  label,
  value,
  delta,
  spark,
  variant = 'light',
  disabled = false,
  disabledLabel = 'Indisponível no momento',
  onClick,
}: DashboardCardProps) {
  const dark = variant !== 'light'
  const bg = dark ? t.component.dashboardTile[variant as DashboardTileCategory] : undefined

  if (disabled) {
    return (
      <div className="relative overflow-hidden rounded-2xl border border-border-default bg-surface-subtle p-4">
        <div className="pointer-events-none opacity-40">
          <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-neutral-200 text-neutral-500">
            <Icon size={18} />
          </span>
          <p className="mt-3 text-sm font-medium text-fg-muted">{label}</p>
          <p className="mt-1 text-2xl font-bold text-fg-subtle">—</p>
        </div>
        <div className="absolute right-3 top-3 text-fg-subtle">
          <Lock size={14} />
        </div>
        <p className="mt-2 text-xs font-medium text-fg-subtle">{disabledLabel}</p>
      </div>
    )
  }

  return (
    <button
      type="button"
      onClick={onClick}
      disabled={!onClick}
      style={dark ? { background: bg } : undefined}
      className={cn(
        'flex flex-col rounded-2xl p-4 text-left shadow-card transition-shadow',
        onClick && 'hover:shadow-card-hover active:scale-[0.99]',
        dark ? 'text-white' : 'border border-border-default bg-surface',
      )}
    >
      <div className="flex items-start justify-between">
        <span
          className={cn(
            'flex h-9 w-9 items-center justify-center rounded-xl',
            dark ? 'bg-white/15 text-white' : 'bg-accent-subtle text-accent',
          )}
        >
          <Icon size={18} />
        </span>
        {typeof delta === 'number' && (
          <span
            className={cn(
              'flex items-center gap-0.5 text-xs font-semibold',
              dark ? 'text-white/90' : delta >= 0 ? 'text-brand-600' : 'text-red-600',
            )}
          >
            {delta >= 0 ? <TrendingUp size={13} /> : <TrendingDown size={13} />}
            {delta >= 0 ? '+' : ''}
            {delta}%
          </span>
        )}
      </div>
      <p className={cn('mt-3 text-sm font-medium', dark ? 'text-white/75' : 'text-fg-muted')}>{label}</p>
      <p className="mt-0.5 text-2xl font-bold leading-tight">{value}</p>
      {spark && (
        <div className="mt-2">
          <SparklineArea data={spark} color={dark ? 'rgba(255,255,255,0.9)' : t.color.brand[600]} width={220} height={34} className="w-full" />
        </div>
      )}
    </button>
  )
}
