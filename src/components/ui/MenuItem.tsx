import { ChevronRight, type LucideIcon } from 'lucide-react'
import type { ReactNode } from 'react'
import { cn } from '@/lib/cn'

export type MenuItemTone = 'default' | 'danger'
export type MenuItemVariant = 'light' | 'onDark'

export interface MenuItemProps {
  icon?: LucideIcon
  label: string
  description?: string
  trailing?: ReactNode
  active?: boolean
  tone?: MenuItemTone
  variant?: MenuItemVariant
  onClick?: () => void
  className?: string
}

const containerVariantCls: Record<MenuItemVariant, string> = {
  light: 'bg-surface shadow-card hover:bg-surface-subtle',
  onDark: 'bg-ink-bubble hover:bg-white/10',
}

const containerActiveCls: Record<MenuItemVariant, string> = {
  light: 'bg-accent-subtle shadow-card',
  onDark: 'bg-white/15',
}

const labelVariantCls: Record<MenuItemVariant, string> = {
  light: 'text-fg',
  onDark: 'text-ink-fg',
}

const labelActiveCls: Record<MenuItemVariant, string> = {
  light: 'text-accent',
  onDark: 'text-ink-fg',
}

const labelDangerCls: Record<MenuItemVariant, string> = {
  light: 'text-red-600',
  onDark: 'text-red-400',
}

const iconBubbleCls: Record<MenuItemVariant, string> = {
  light: 'bg-surface-subtle text-fg-muted',
  onDark: 'bg-ink-bubble text-ink-fg',
}

const descriptionVariantCls: Record<MenuItemVariant, string> = {
  light: 'text-fg-muted',
  onDark: 'text-ink-muted',
}

const chevronCls: Record<MenuItemVariant, string> = {
  light: 'bg-surface-subtle text-fg-muted',
  onDark: 'bg-ink-bubble text-ink-muted',
}

/**
 * Item de menu/navegação (Nova UI): linha-cápsula com bolha de ícone à esquerda,
 * título + descrição e chevron em círculo à direita (referência). Touch target ≥ 56px.
 */
export function MenuItem({
  icon: Icon,
  label,
  description,
  trailing,
  active = false,
  tone = 'default',
  variant = 'light',
  onClick,
  className,
}: MenuItemProps) {
  const isDanger = tone === 'danger'

  return (
    <button
      type="button"
      onClick={onClick}
      aria-current={active ? 'page' : undefined}
      className={cn(
        'flex min-h-14 w-full items-center gap-3 rounded-2xl px-3 py-2 text-left transition-colors',
        active ? containerActiveCls[variant] : containerVariantCls[variant],
        className,
      )}
    >
      {Icon && (
        <span
          className={cn(
            'flex h-10 w-10 shrink-0 items-center justify-center rounded-full',
            isDanger ? 'bg-red-500/10 text-red-500' : iconBubbleCls[variant],
          )}
        >
          <Icon size={19} strokeWidth={1.9} aria-hidden="true" />
        </span>
      )}
      <span className="flex min-w-0 flex-1 flex-col">
        <span
          className={cn(
            'truncate text-md font-semibold',
            isDanger ? labelDangerCls[variant] : active ? labelActiveCls[variant] : labelVariantCls[variant],
          )}
        >
          {label}
        </span>
        {description && (
          <span className={cn('truncate text-xs', descriptionVariantCls[variant])}>{description}</span>
        )}
      </span>
      {trailing ? (
        <span className="ml-auto flex shrink-0 items-center">{trailing}</span>
      ) : (
        onClick && (
          <span
            aria-hidden="true"
            className={cn('ml-auto flex h-8 w-8 shrink-0 items-center justify-center rounded-full', chevronCls[variant])}
          >
            <ChevronRight size={15} strokeWidth={2.2} />
          </span>
        )
      )}
    </button>
  )
}
