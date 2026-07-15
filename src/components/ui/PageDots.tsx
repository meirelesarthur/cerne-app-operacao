import { cn } from '@/lib/cn'

export interface PageDotsProps {
  /** total de páginas */
  count: number
  /** índice da página ativa (0-based) */
  active: number
  /** callback ao tocar num dot — se ausente, os dots são apenas indicativos */
  onSelect?: (index: number) => void
  className?: string
}

/**
 * Indicador de páginas (carrossel/onboarding): dots pequenos, o ativo alonga
 * em pílula na cor accent. Interativo quando `onSelect` é fornecido.
 */
export function PageDots({ count, active, onSelect, className }: PageDotsProps) {
  return (
    <div className={cn('flex items-center justify-center gap-2', className)} role="tablist" aria-label="Páginas">
      {Array.from({ length: count }, (_, i) => {
        const isActive = i === active
        return (
          <button
            key={i}
            type="button"
            role="tab"
            aria-selected={isActive}
            aria-label={`Página ${i + 1} de ${count}`}
            disabled={!onSelect}
            onClick={() => onSelect?.(i)}
            className={cn(
              'h-2 rounded-full transition-all duration-slow ease-out',
              isActive ? 'w-6 bg-accent' : 'w-2 bg-border-default',
              !onSelect && 'cursor-default',
            )}
          />
        )
      })}
    </div>
  )
}
