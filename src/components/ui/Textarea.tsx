import type { TextareaHTMLAttributes } from 'react'
import { cn } from '@/lib/cn'

export function Textarea({ className, ...rest }: TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return (
    <textarea
      className={cn(
        'min-h-[80px] w-full rounded-lg border border-border-default bg-surface px-3 py-2 text-md text-fg',
        'placeholder:text-fg-subtle focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent/40',
        className,
      )}
      {...rest}
    />
  )
}
