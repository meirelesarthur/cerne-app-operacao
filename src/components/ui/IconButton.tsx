import type { ButtonHTMLAttributes, ReactNode } from 'react'
import { cn } from '@/lib/cn'

type Size = 'sm' | 'md' | 'lg'

export interface IconButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  size?: Size
  label: string // acessibilidade obrigatória
  children: ReactNode
  variant?: 'ghost' | 'solid' | 'onDark'
}

const sizeCls: Record<Size, string> = {
  sm: 'h-6 w-6',
  md: 'h-[30px] w-[30px]',
  lg: 'h-9 w-9',
}

const variantCls = {
  ghost: 'text-fg hover:bg-surface-subtle',
  solid: 'bg-surface border border-border-default text-fg hover:bg-surface-subtle',
  onDark: 'text-white/90 hover:bg-white/10',
} as const

export function IconButton({ size = 'md', label, children, variant = 'ghost', className, ...rest }: IconButtonProps) {
  return (
    <button
      type="button"
      aria-label={label}
      title={label}
      className={cn(
        'inline-flex items-center justify-center rounded-lg transition-colors focus-visible:outline-none',
        sizeCls[size],
        variantCls[variant],
        className,
      )}
      {...rest}
    >
      {children}
    </button>
  )
}
