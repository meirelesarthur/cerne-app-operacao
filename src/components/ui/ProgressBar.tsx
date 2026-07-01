import { cn } from '@/lib/cn'

export interface ProgressBarProps {
  value: number
  max?: number
  /** cor por ocupação (spec §4.2): verde <80%, amber 80–99%, vermelho ≥100%. */
  colorByOccupancy?: boolean
  tone?: 'brand' | 'blue' | 'amber' | 'red'
  className?: string
  showLabel?: boolean
}

function occupancyTone(pct: number): NonNullable<ProgressBarProps['tone']> {
  if (pct >= 100) return 'red'
  if (pct >= 80) return 'amber'
  return 'brand'
}

const toneCls = {
  brand: 'bg-accent',
  blue: 'bg-blue-500',
  amber: 'bg-amber-500',
  red: 'bg-red-500',
} as const

export function ProgressBar({ value, max = 100, colorByOccupancy, tone = 'brand', className, showLabel }: ProgressBarProps) {
  const pct = Math.min((value / max) * 100, 100)
  const rawPct = (value / max) * 100
  const activeTone = colorByOccupancy ? occupancyTone(rawPct) : tone

  return (
    <div className={className}>
      <div className="h-2 w-full overflow-hidden rounded-full bg-surface-subtle">
        <div className={cn('h-full rounded-full transition-all', toneCls[activeTone])} style={{ width: `${pct}%` }} />
      </div>
      {showLabel && <p className="mt-1 text-xs font-medium text-fg-muted">{Math.round(rawPct)}%</p>}
    </div>
  )
}
