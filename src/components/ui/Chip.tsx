import type { ReactNode } from 'react'
import { cn } from '@/lib/cn'

/** Cor semântica única e parametrizável (spec §6.9) — reutilizada em todos os badges de status. */
export type ChipTone = 'brand' | 'blue' | 'amber' | 'red' | 'neutral'

export interface ChipProps {
  tone?: ChipTone
  children: ReactNode
  icon?: ReactNode
  className?: string
}

const toneCls: Record<ChipTone, string> = {
  brand: 'bg-brand-50 text-brand-700 border-brand-200',
  blue: 'bg-blue-50 text-blue-600 border-blue-200',
  amber: 'bg-amber-50 text-amber-600 border-amber-200',
  red: 'bg-red-50 text-red-600 border-red-200',
  neutral: 'bg-neutral-100 text-neutral-600 border-neutral-200',
}

export function Chip({ tone = 'neutral', children, icon, className }: ChipProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1 rounded-full border px-2 py-0.5 text-xs font-semibold whitespace-nowrap',
        toneCls[tone],
        className,
      )}
    >
      {icon}
      {children}
    </span>
  )
}
