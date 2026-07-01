import type { ReactNode } from 'react'
import { cn } from '@/lib/cn'

export type BannerTone = 'info' | 'warning' | 'success' | 'error' | 'offline'

export interface BannerProps {
  tone?: BannerTone
  icon?: ReactNode
  children: ReactNode
  action?: ReactNode
  className?: string
}

const toneCls: Record<BannerTone, string> = {
  info: 'bg-blue-50 text-blue-700 border-blue-200',
  warning: 'bg-amber-50 text-amber-700 border-amber-200',
  success: 'bg-brand-50 text-brand-700 border-brand-200',
  error: 'bg-red-50 text-red-700 border-red-200',
  offline: 'bg-amber-100 text-amber-800 border-amber-300',
}

/** Faixa fina no topo do conteúdo (spec §6.10) — offline/sync e avisos contextuais. */
export function Banner({ tone = 'info', icon, children, action, className }: BannerProps) {
  return (
    <div
      className={cn(
        'flex items-center gap-2 border-b px-4 py-2 text-xs font-medium',
        toneCls[tone],
        className,
      )}
      role="status"
    >
      {icon}
      <span className="flex-1">{children}</span>
      {action}
    </div>
  )
}
