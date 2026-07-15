import type { LucideIcon } from 'lucide-react'
import { ArrowRight } from 'lucide-react'
import { t } from '@/design/tokens'
import { cn } from '@/lib/cn'

export interface BentoTileProps {
  icon: LucideIcon
  label: string
  caption?: string
  /** tom do container do ícone na variante 'surface' (usa paleta de acento) */
  tone?: 'brand' | 'blue' | 'amber' | 'purple'
  /** 'surface' (padrão, clara) ou 'accent' (escura, tile de destaque com seta) */
  variant?: 'surface' | 'accent'
  /** tamanho do container/ícone */
  iconSize?: 'md' | 'lg'
  onClick?: () => void
  className?: string
}

const toneCls: Record<NonNullable<BentoTileProps['tone']>, string> = {
  brand: 'bg-accent-subtle text-accent border border-border-tint',
  blue: 'bg-blue-50 text-blue-600 border border-blue-100',
  amber: 'bg-amber-50 text-amber-600 border border-amber-100',
  purple: '',
}

/**
 * Tile de bento grid reutilizável (home de super app): tamanhos mistos,
 * variante clara ('surface') ou escura de destaque com seta ('accent').
 */
export function BentoTile({
  icon: Icon,
  label,
  caption,
  tone = 'brand',
  variant = 'surface',
  iconSize = 'md',
  onClick,
  className,
}: BentoTileProps) {
  const iconBoxCls = iconSize === 'lg' ? 'h-12 w-12' : 'h-11 w-11'
  const iconGlyphSize = iconSize === 'lg' ? 26 : 22

  if (variant === 'accent') {
    return (
      <button
        type="button"
        onClick={onClick}
        style={{ background: `linear-gradient(135deg, ${t.component.hub.bankCard.from}, ${t.component.hub.bankCard.to})` }}
        className={cn(
          'relative flex h-full min-h-[104px] w-full flex-col items-start justify-between gap-3 rounded-3xl p-4 text-left transition-all hover:shadow-card-hover active:scale-[0.97]',
          className,
        )}
      >
        <span className={cn('flex items-center justify-center rounded-full bg-white/15 text-white', iconBoxCls)}>
          <Icon size={iconGlyphSize} aria-hidden="true" />
        </span>
        <div className="min-w-0 pr-8">
          <p className="text-sm font-semibold text-white">{label}</p>
          {caption && <p className="mt-0.5 text-xs leading-snug text-white/70">{caption}</p>}
        </div>
        <span
          aria-hidden="true"
          className="absolute bottom-4 right-4 flex h-8 w-8 items-center justify-center rounded-full bg-white/15"
        >
          <ArrowRight size={16} className="text-white" />
        </span>
      </button>
    )
  }

  const isPurple = tone === 'purple'

  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        'flex h-full min-h-[104px] w-full flex-col items-start justify-between gap-3 rounded-3xl border border-border-subtle bg-surface p-4 text-left shadow-card transition-all hover:shadow-card-hover active:scale-[0.97]',
        className,
      )}
    >
      <span
        className={cn('flex items-center justify-center rounded-full', iconBoxCls, !isPurple && toneCls[tone])}
        style={
          isPurple
            ? {
                backgroundColor: t.color.accent.purple.bg,
                color: t.color.accent.purple.solid,
                border: `1px solid ${t.color.accent.purple.border}`,
              }
            : undefined
        }
      >
        <Icon size={iconGlyphSize} aria-hidden="true" />
      </span>
      <div className="min-w-0">
        <p className="text-sm font-semibold text-fg">{label}</p>
        {caption && <p className="mt-0.5 text-xs leading-snug text-fg-muted">{caption}</p>}
      </div>
    </button>
  )
}
