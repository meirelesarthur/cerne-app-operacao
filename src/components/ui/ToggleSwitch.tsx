import { cn } from '@/lib/cn'

export interface ToggleSwitchProps {
  checked: boolean
  onChange: (v: boolean) => void
  /** Rótulo acessível (aria-label) — obrigatório para o role=switch. */
  label: string
  disabled?: boolean
  className?: string
}

/**
 * Interruptor on/off acessível (role="switch"), operável por teclado e leitores
 * de tela. Encapsula o controle nativo para cumprir a Lei 1.
 */
export function ToggleSwitch({ checked, onChange, label, disabled = false, className }: ToggleSwitchProps) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      disabled={disabled}
      onClick={() => onChange(!checked)}
      className={cn(
        'relative inline-flex h-6 w-11 shrink-0 cursor-pointer items-center rounded-full transition-colors',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent/40',
        checked ? 'bg-accent' : 'bg-neutral-300',
        disabled && 'cursor-not-allowed opacity-50',
        className,
      )}
    >
      <span
        className={cn(
          'inline-block h-5 w-5 transform rounded-full bg-surface shadow-card transition-transform',
          checked ? 'translate-x-5' : 'translate-x-0.5',
        )}
      />
    </button>
  )
}
