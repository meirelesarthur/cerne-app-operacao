import type { HTMLAttributes, KeyboardEvent, MouseEvent, ReactNode } from 'react'
import { cn } from '@/lib/cn'

export interface CardProps extends HTMLAttributes<HTMLDivElement> {
  children: ReactNode
  interactive?: boolean
  padded?: boolean
}

export function Card({ children, interactive = false, padded = true, className, onClick, ...rest }: CardProps) {
  // card clicável é operável por teclado (Enter/Espaço) — WCAG 2.1
  const a11y =
    interactive && onClick
      ? {
          role: 'button',
          tabIndex: 0,
          onKeyDown: (e: KeyboardEvent<HTMLDivElement>) => {
            if (e.key === 'Enter' || e.key === ' ') {
              e.preventDefault()
              onClick(e as unknown as MouseEvent<HTMLDivElement>)
            }
          },
        }
      : {}

  return (
    <div
      className={cn(
        'rounded-2xl bg-surface border border-border-default shadow-card',
        padded && 'p-4',
        interactive && 'cursor-pointer transition-shadow hover:shadow-card-hover active:scale-[0.99]',
        className,
      )}
      onClick={onClick}
      {...a11y}
      {...rest}
    >
      {children}
    </div>
  )
}
