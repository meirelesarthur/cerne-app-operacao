import type { SelectHTMLAttributes } from 'react'
import { ChevronDown } from 'lucide-react'
import { cn } from '@/lib/cn'

export interface FormSelectOption {
  value: string
  label: string
}

export interface FormSelectProps extends Omit<SelectHTMLAttributes<HTMLSelectElement>, 'children'> {
  options: FormSelectOption[]
  placeholder?: string
}

export function FormSelect({ options, placeholder, className, ...rest }: FormSelectProps) {
  return (
    <div className="relative">
      <select
        className={cn(
          'h-10 w-full appearance-none rounded-lg border border-border-default bg-surface px-3 pr-9 text-md text-fg',
          'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent/40',
          className,
        )}
        {...rest}
      >
        {placeholder && <option value="">{placeholder}</option>}
        {options.map((o) => (
          <option key={o.value} value={o.value}>
            {o.label}
          </option>
        ))}
      </select>
      <ChevronDown size={16} className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-fg-subtle" />
    </div>
  )
}
