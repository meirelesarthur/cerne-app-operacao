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
 * Área de ilustração (onboarding/empty states premium): arco suave em tons da
 * marca ao fundo, com slot para a arte final. Enquanto a imagem gerada não é
 * fornecida via `src`, renderiza um fallback tokenizado com o ícone do tema —
 * basta trocar o `src` quando a ilustração ficar pronta, sem tocar no layout.
 */
export function IllustrationSlot({ src, alt, icon: Icon, className }: IllustrationSlotProps) {
  return (
    <div className={cn('relative mx-auto flex aspect-square w-full max-w-[280px] items-end justify-center', className)}>
      {/* arco de fundo (estilo referência: meia-lua atrás da arte) */}
      <div
        aria-hidden="true"
        className="absolute inset-x-0 bottom-0 h-[82%] rounded-t-full bg-accent-subtle"
      />
      {src ? (
        <img src={src} alt={alt} className="relative z-10 h-full w-full object-contain" />
      ) : (
        <div role="img" aria-label={alt} className="relative z-10 flex h-full w-full items-center justify-center">
          {Icon && (
            <span className="flex h-24 w-24 items-center justify-center rounded-[32px] bg-accent text-white shadow-brand">
              <Icon size={44} strokeWidth={1.6} />
            </span>
          )}
        </div>
      )}
    </div>
  )
}
