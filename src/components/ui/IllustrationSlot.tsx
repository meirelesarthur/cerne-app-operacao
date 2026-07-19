import type { LucideIcon } from 'lucide-react'
import { cn } from '@/lib/cn'

export interface IllustrationSlotProps {
  /** caminho da ilustração gerada (ex.: /illustrations/onboarding-1.png). Sem src, mostra o fallback com ícone. */
  src?: string
  /** descrição acessível da ilustração */
  alt: string
  /** ícone de fallback enquanto a arte final não existe */
  icon?: LucideIcon
  className?: string
}

/**
 * Área de ilustração (onboarding/empty states premium). Com `src`, a arte final
 * é autocontida (as ilustrações geradas já trazem o próprio fundo) — sem arco
 * decorativo por trás. Sem `src`, renderiza o fallback tokenizado: bolha ink
 * com o ícone do tema, no idioma da Nova UI — trocar para a arte pronta não
 * exige mexer no layout.
 */
export function IllustrationSlot({ src, alt, icon: Icon, className }: IllustrationSlotProps) {
  if (src) {
    return <img src={src} alt={alt} className={cn('mx-auto w-full max-w-[300px] object-contain', className)} />
  }

  return (
    <div className={cn('relative mx-auto flex aspect-square w-full max-w-[280px] items-center justify-center', className)}>
      <div role="img" aria-label={alt} className="relative z-10 flex h-full w-full items-center justify-center">
        {Icon && (
          <span className="flex h-24 w-24 items-center justify-center rounded-[32px] bg-ink text-cta shadow-card">
            <Icon size={44} strokeWidth={1.6} />
          </span>
        )}
      </div>
    </div>
  )
}
