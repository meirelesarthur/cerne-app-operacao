import type { ButtonHTMLAttributes } from 'react'
import { cn } from '@/lib/cn'

export interface PressableProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  /** Mantém o alvo mínimo recomendado para interação mobile. */
  minTouchTarget?: boolean
}

/**
 * Primitivo sem aparência própria para superfícies interativas customizadas.
 * Centraliza semântica, foco, cursor e alvo de toque sem competir com Button.
 */
export function Pressable({
  type = 'button',
  minTouchTarget = true,
  disabled,
  className,
  ...rest
}: PressableProps) {
  return (
    <button
      type={type}
      disabled={disabled}
      className={cn(
        'cursor-pointer disabled:cursor-not-allowed disabled:opacity-70',
        minTouchTarget && 'min-h-11 min-w-11',
        className,
      )}
      {...rest}
    />
  )
}
