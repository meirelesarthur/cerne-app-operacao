import type { TextareaHTMLAttributes } from 'react'
import { cn } from '@/lib/cn'

export function Textarea({ className, ...rest }: TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return (
    <textarea
      className={cn(
        'min-h-[96px] w-full rounded-2xl border border-transparent bg-surface-subtle px-5 py-3 text-md text-fg',
        'transition-colors placeholder:text-fg-subtle focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent/40 focus-visible:bg-surface',
        className,
      )}
      {...rest}
    />
  )
}
