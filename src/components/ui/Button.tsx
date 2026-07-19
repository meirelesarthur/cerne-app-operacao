import type { ButtonHTMLAttributes, ReactNode } from 'react'
import { cn } from '@/lib/cn'
import { Spinner } from './Spinner'

type Variant = 'primary' | 'secondary' | 'ghost' | 'danger' | 'link'
type Size = 'sm' | 'md' | 'lg'

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant
  size?: Size
  loading?: boolean
  fullWidth?: boolean
  leftIcon?: ReactNode
  rightIcon?: ReactNode
}

const sizeCls: Record<Size, string> = {
  sm: 'h-9 px-4 text-sm gap-1.5',
  md: 'h-11 px-5 text-md gap-2',
  lg: 'h-[52px] px-6 text-lg gap-2',
}

// Nova UI: pílulas cheias; primary é o CTA vibrante (verde + texto quase-preto) da referência
const variantCls: Record<Variant, string> = {
  primary: 'bg-cta text-cta-fg hover:bg-cta-hover disabled:bg-neutral-300 disabled:text-neutral-500',
  secondary: 'bg-surface text-fg border border-border-default shadow-card hover:bg-surface-subtle',
  ghost: 'bg-transparent text-fg hover:bg-surface-subtle',
  danger: 'bg-red-600 text-white hover:bg-red-700',
  // link inline: sem caixa — altura/padding zerados abaixo
  link: 'bg-transparent text-accent hover:text-accent-hover hover:underline underline-offset-2',
}

export function Button({
  variant = 'primary',
  size = 'md',
  loading = false,
  fullWidth = false,
  leftIcon,
  rightIcon,
  disabled,
  children,
  className,
  ...rest
}: ButtonProps) {
  return (
    <button
      className={cn(
        'inline-flex items-center justify-center rounded-full font-semibold transition-all active:scale-[0.98]',
        'focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-70',
        variant === 'link' ? 'h-auto gap-1 p-0 text-sm' : sizeCls[size],
        variantCls[variant],
        fullWidth && 'w-full',
        className,
      )}
      disabled={disabled || loading}
      {...rest}
    >
      {loading ? <Spinner size={size === 'lg' ? 20 : 16} /> : leftIcon}
      {children}
      {!loading && rightIcon}
    </button>
  )
}
