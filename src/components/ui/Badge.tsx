import type { ReactNode } from 'react'
import { cn } from '@/lib/cn'

/** Contador/indicador numérico compacto (ex.: badge do sino de notificações). */
export interface BadgeProps {
  children: ReactNode
  tone?: 'brand' | 'red' | 'neutral'
  className?: string
}

const toneCls = {
  brand: 'bg-accent text-white',
  red: 'bg-red-600 text-white',
  neutral: 'bg-neutral-200 text-neutral-700',
} as const

export function Badge({ children, tone = 'red', className }: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex min-w-[18px] h-[18px] items-center justify-center rounded-full px-1 text-[10px] font-bold leading-none',
        toneCls[tone],
        className,
      )}
    >
      {children}
    </span>
  )
}
