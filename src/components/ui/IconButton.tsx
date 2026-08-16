import type { ButtonHTMLAttributes, ReactNode } from 'react'
import { cn } from '@/lib/cn'

type Size = 'sm' | 'md' | 'lg'

export interface IconButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  size?: Size
  label: string // acessibilidade obrigatória
  children: ReactNode
  variant?: 'ghost' | 'solid' | 'onDark'
}

// Nova UI: bolhas circulares (referência) — touch targets generosos
const sizeCls: Record<Size, string> = {
  sm: 'h-11 w-11',
  md: 'h-11 w-11',
  lg: 'h-12 w-12',
}

const variantCls = {
  ghost: 'text-fg hover:bg-surface-subtle',
  // bolha branca/surface com sombra suave — botões circulares do header da referência
  solid: 'bg-surface text-fg shadow-card hover:bg-surface-subtle',
  // bolha translúcida sobre superfícies ink/escuras
  onDark: 'bg-ink-bubble text-ink-fg hover:bg-white/15',
} as const

export function IconButton({ size = 'md', label, children, variant = 'ghost', className, ...rest }: IconButtonProps) {
  return (
    <button
      type="button"
      aria-label={label}
      title={label}
      className={cn(
        'inline-flex shrink-0 items-center justify-center rounded-full transition-all active:scale-95',
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
