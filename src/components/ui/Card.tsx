import type { HTMLAttributes, ReactNode } from 'react'
import { cn } from '@/lib/cn'

export interface CardProps extends HTMLAttributes<HTMLDivElement> {
  children: ReactNode
  interactive?: boolean
  padded?: boolean
}

export function Card({ children, interactive = false, padded = true, className, ...rest }: CardProps) {
  return (
    <div
      className={cn(
        'rounded-2xl bg-surface border border-border-default shadow-card',
        padded && 'p-4',
        interactive && 'cursor-pointer transition-shadow hover:shadow-card-hover active:scale-[0.99]',
        className,
      )}
      {...rest}
    >
      {children}
    </div>
  )
}
