import { useState, type ReactNode } from 'react'
import { cn } from '@/lib/cn'

export interface TooltipProps {
  content: string
  children: ReactNode
  className?: string
}

/**
 * Tooltip simples (hover/focus). Em mobile, também abre no toque.
 * Implementação leve baseada em estado, sem dependência externa.
 */
export function Tooltip({ content, children, className }: TooltipProps) {
  const [open, setOpen] = useState(false)

  return (
    <span
      className={cn('relative inline-flex', className)}
      onMouseEnter={() => setOpen(true)}
      onMouseLeave={() => setOpen(false)}
      onFocus={() => setOpen(true)}
      onBlur={() => setOpen(false)}
      onClick={() => setOpen((o) => !o)}
      tabIndex={0}
    >
      {children}
      {open && (
        <span
          role="tooltip"
          className="absolute bottom-full right-0 z-[1100] mb-1 w-max max-w-[200px] rounded-lg bg-neutral-900 px-2 py-1 text-xs font-medium text-white shadow-modal"
        >
          {content}
        </span>
      )}
    </span>
  )
}
