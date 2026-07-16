import type { LucideIcon } from 'lucide-react'
import { ArrowRight } from 'lucide-react'
import { t } from '@/design/tokens'
import { cn } from '@/lib/cn'

export interface BentoTileProps {
  icon: LucideIcon
  label: string
  caption?: string
  /** 'surface' (padrão, clara) ou 'accent' (escura, tile de destaque com seta) */
  variant?: 'surface' | 'accent'
  /** tamanho do container/ícone */
  iconSize?: 'md' | 'lg'
  onClick?: () => void
  className?: string
}

/**
 * Tile de bento grid reutilizável (home de super app): tamanhos mistos,
 * variante clara ('surface') ou escura de destaque com seta ('accent').
 * Nova UI: bolha de ícone monotom (acento da marca) — sem cor por item; a
 * distinção vem do ícone e do rótulo, não do fundo.
 */
export function BentoTile({
  icon: Icon,
  label,
  caption,
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
        className={cn(
          'flex items-center justify-center rounded-full border border-border-tint bg-accent-subtle text-accent',
          iconBoxCls,
        )}
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
