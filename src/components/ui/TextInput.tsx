import type { InputHTMLAttributes } from 'react'
import { cn } from '@/lib/cn'

export interface TextInputProps extends InputHTMLAttributes<HTMLInputElement> {
  invalid?: boolean
}

export function TextInput({ invalid, className, ...rest }: TextInputProps) {
  return (
    <input
      className={cn(
        // Nova UI: campo-cápsula (referência) — pílula cheia, fundo sutil, sem borda dura
        'h-12 w-full rounded-full border bg-surface-subtle px-5 text-md text-fg placeholder:text-fg-subtle',
        'transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent/40 focus-visible:bg-surface',
        invalid ? 'border-red-500' : 'border-transparent',
        'disabled:bg-surface-subtle disabled:text-fg-muted',
        className,
      )}
      {...rest}
    />
  )
}
