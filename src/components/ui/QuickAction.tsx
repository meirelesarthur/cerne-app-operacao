import type { LucideIcon } from 'lucide-react'
import { cn } from '@/lib/cn'

export interface QuickActionProps {
  icon: LucideIcon
  label: string
  onClick?: () => void
  className?: string
}

/**
 * Ação rápida do hub (New-UI): círculo de 56px (touch target > 44px) com feedback
 * de pressão em scale — transform+opacity apenas, sem layout shift.
 */
export function QuickAction({ icon: Icon, label, onClick, className }: QuickActionProps) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn('group flex flex-col items-center gap-1.5', className)}
    >
      <span
        className={cn(
          'flex h-14 w-14 items-center justify-center rounded-full border border-border-tint bg-accent-subtle text-accent',
          'transition-all group-hover:border-border-strong group-active:scale-95',
        )}
      >
        <Icon size={22} strokeWidth={2} aria-hidden="true" />
      </span>
      <span className="text-center text-xs font-medium leading-tight text-fg-muted">{label}</span>
    </button>
  )
}
