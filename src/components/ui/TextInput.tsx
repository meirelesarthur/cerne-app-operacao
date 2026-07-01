import type { InputHTMLAttributes } from 'react'
import { cn } from '@/lib/cn'

export interface TextInputProps extends InputHTMLAttributes<HTMLInputElement> {
  invalid?: boolean
}

export function TextInput({ invalid, className, ...rest }: TextInputProps) {
  return (
    <input
      className={cn(
        'h-10 w-full rounded-lg border bg-surface px-3 text-md text-fg placeholder:text-fg-subtle',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent/40',
        invalid ? 'border-red-500' : 'border-border-default',
        'disabled:bg-surface-subtle disabled:text-fg-muted',
        className,
      )}
      {...rest}
    />
  )
}
