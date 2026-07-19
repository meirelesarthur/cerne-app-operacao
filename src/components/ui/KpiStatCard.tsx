import { cn } from '@/lib/cn'

type Tone = 'default' | 'positive' | 'negative' | 'warning'

export interface KpiStatCardProps {
  label: string
  value: string
  caption?: string
  tone?: Tone
  className?: string
}

const valueToneCls: Record<Tone, string> = {
  default: 'text-fg',
  positive: 'text-brand-600',
  negative: 'text-red-600',
  warning: 'text-amber-600',
}

/** Card-resumo compacto para as linhas de KPIs do topo dos dashboards. */
export function KpiStatCard({ label, value, caption, tone = 'default', className }: KpiStatCardProps) {
  return (
    <div className={cn('rounded-2xl border border-border-subtle bg-surface p-4 shadow-card', className)}>
      <p className="text-xs font-medium text-fg-muted">{label}</p>
      <p className={cn('mt-1 text-xl font-bold leading-tight', valueToneCls[tone])}>{value}</p>
      {caption && <p className="mt-0.5 text-xs text-fg-subtle">{caption}</p>}
    </div>
  )
}
