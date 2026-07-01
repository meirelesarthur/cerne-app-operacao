import type { ReactNode } from 'react'
import { cn } from '@/lib/cn'

/** Rótulo neutro para metadados (categoria, tipo). Diferente do Chip (status semântico). */
export interface TagProps {
  children: ReactNode
  className?: string
}

export function Tag({ children, className }: TagProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-md bg-surface-subtle border border-border-default px-2 py-0.5 text-xs text-fg-muted',
        className,
      )}
    >
      {children}
    </span>
  )
}
