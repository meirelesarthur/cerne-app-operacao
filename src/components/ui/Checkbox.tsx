import { Check } from 'lucide-react'
import { cn } from '@/lib/cn'

export interface CheckboxProps {
  checked: boolean
  onChange: (checked: boolean) => void
  label?: string
  className?: string
}

export function Checkbox({ checked, onChange, label, className }: CheckboxProps) {
  return (
    <button
      type="button"
      role="checkbox"
      aria-checked={checked}
      onClick={() => onChange(!checked)}
      className={cn('inline-flex items-center gap-2', className)}
    >
      <span
        className={cn(
          'flex h-5 w-5 items-center justify-center rounded-md border transition-colors',
          checked ? 'border-accent bg-accent text-white' : 'border-border-strong bg-surface',
        )}
      >
        {checked && <Check size={13} strokeWidth={3} />}
      </span>
      {label && <span className="text-md text-fg">{label}</span>}
    </button>
  )
}
