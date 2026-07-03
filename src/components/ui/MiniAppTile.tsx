import type { LucideIcon } from 'lucide-react'
import { Chip } from './Chip'
import { cn } from '@/lib/cn'

export interface MiniAppTileProps {
  icon: LucideIcon
  name: string
  description?: string
  /** selo de estado do mini-app dentro do hub */
  badge?: 'novo' | 'breve'
  /** mini-app ainda não disponível (ex.: em discovery) */
  disabled?: boolean
  onClick?: () => void
  className?: string
}

/**
 * Tile de mini-app do hub agregador (New-UI). Contrato visual único para
 * injeção contínua de novos apps sem quebrar a arquitetura da informação:
 * ícone tokenizado + nome + descrição + selo de estado.
 */
export function MiniAppTile({ icon: Icon, name, description, badge, disabled = false, onClick, className }: MiniAppTileProps) {
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      className={cn(
        'flex min-h-[96px] flex-col items-start gap-2 rounded-2xl border border-border-default bg-surface p-3 text-left shadow-card',
        'transition-all hover:shadow-card-hover active:scale-[0.98]',
        disabled && 'cursor-not-allowed opacity-50 hover:shadow-card active:scale-100',
        className,
      )}
    >
      <div className="flex w-full items-start justify-between">
        <span className="flex h-10 w-10 items-center justify-center rounded-xl bg-accent-subtle text-accent">
          <Icon size={20} strokeWidth={1.8} aria-hidden="true" />
        </span>
        {badge === 'novo' && <Chip tone="brand">Novo</Chip>}
        {badge === 'breve' && <Chip tone="neutral">Em breve</Chip>}
      </div>
      <div className="min-w-0">
        <p className="text-sm font-semibold text-fg">{name}</p>
        {description && <p className="mt-0.5 line-clamp-2 text-xs leading-snug text-fg-muted">{description}</p>}
      </div>
    </button>
  )
}
