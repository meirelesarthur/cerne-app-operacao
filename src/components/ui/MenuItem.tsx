import type { LucideIcon } from 'lucide-react'
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
  light: 'hover:bg-surface-subtle',
  onDark: 'hover:bg-white/10',
}

const containerActiveCls: Record<MenuItemVariant, string> = {
  light: 'bg-accent-subtle',
  onDark: 'bg-white/15',
}

const labelVariantCls: Record<MenuItemVariant, string> = {
  light: 'text-fg',
  onDark: 'text-white/90',
}

const labelActiveCls: Record<MenuItemVariant, string> = {
  light: 'text-accent',
  onDark: 'text-white',
}

const labelDangerCls: Record<MenuItemVariant, string> = {
  light: 'text-red-600',
  onDark: 'text-red-400',
}

const iconVariantCls: Record<MenuItemVariant, string> = {
  light: 'text-fg-muted',
  onDark: 'text-white/70',
}

const descriptionVariantCls: Record<MenuItemVariant, string> = {
  light: 'text-fg-muted',
  onDark: 'text-white/55',
}

/** Item de menu/navegação para drawers e listas de configuração, com touch target mínimo de 44px. */
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
        'flex min-h-11 w-full items-center gap-3 rounded-xl px-3 text-left transition-colors',
        active ? containerActiveCls[variant] : containerVariantCls[variant],
        className,
      )}
    >
      {Icon && (
        <span className={cn('shrink-0', isDanger ? labelDangerCls[variant] : iconVariantCls[variant])}>
          <Icon size={20} strokeWidth={1.8} aria-hidden="true" />
        </span>
      )}
      <span className="flex min-w-0 flex-1 flex-col">
        <span
          className={cn(
            'text-md font-medium truncate',
            isDanger ? labelDangerCls[variant] : active ? labelActiveCls[variant] : labelVariantCls[variant],
          )}
        >
          {label}
        </span>
        {description && (
          <span className={cn('text-xs truncate', descriptionVariantCls[variant])}>{description}</span>
        )}
      </span>
      {trailing && <span className="ml-auto flex shrink-0 items-center">{trailing}</span>}
    </button>
  )
}
