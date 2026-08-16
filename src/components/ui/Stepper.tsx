import { Minus, Plus } from 'lucide-react'
import { cn } from '@/lib/cn'

export interface StepperProps {
  value: number
  onChange: (v: number) => void
  min?: number
  max?: number
  step?: number
  suffix?: string
  className?: string
}

/** Stepper numérico (quantidade). Encapsula o input para cumprir a Lei 1. */
export function Stepper({ value, onChange, min = 0, max = Infinity, step = 1, suffix, className }: StepperProps) {
  const clamp = (v: number) => Math.min(Math.max(v, min), max)
  return (
    <div className={cn('flex h-11 items-stretch overflow-hidden rounded-lg border border-border-default bg-surface', className)}>
      <button
        type="button"
        aria-label="Diminuir"
        onClick={() => onChange(clamp(value - step))}
        className="flex w-11 items-center justify-center text-fg-muted hover:bg-surface-subtle disabled:opacity-40"
        disabled={value <= min}
      >
        <Minus size={16} />
      </button>
      <div className="flex flex-1 items-center justify-center gap-1 border-x border-border-default text-md font-semibold text-fg">
        <input
          type="number"
          value={value}
          onChange={(e) => onChange(clamp(Number(e.target.value) || 0))}
          className="w-full [appearance:textfield] bg-transparent text-center outline-none [&::-webkit-inner-spin-button]:appearance-none"
        />
        {suffix && <span className="pr-2 text-sm text-fg-subtle">{suffix}</span>}
      </div>
      <button
        type="button"
        aria-label="Aumentar"
        onClick={() => onChange(clamp(value + step))}
        className="flex w-11 items-center justify-center text-fg-muted hover:bg-surface-subtle disabled:opacity-40"
        disabled={value >= max}
      >
        <Plus size={16} />
      </button>
    </div>
  )
}
