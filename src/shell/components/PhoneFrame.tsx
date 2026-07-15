import type { ReactNode } from 'react'

/**
 * Frame de telefone centralizado — o protótipo é mobile-first (spec §1.4/§7.3).
 * Em mobile ocupa a tela toda (altura fixa no viewport, rolagem interna).
 * Em telas largas mostra o app dentro de um "device": a altura acompanha o viewport
 * disponível (nunca passa de 860px) — a moldura em si não rola, só o conteúdo interno,
 * então tudo cabe numa única dobra.
 */
export function PhoneFrame({ children }: { children: ReactNode }) {
  return (
    <div className="flex h-full justify-center overflow-hidden bg-neutral-200/60 sm:py-6">
      <div className="relative flex h-[100dvh] w-full max-w-phone flex-col overflow-hidden bg-canvas shadow-modal sm:h-[min(860px,calc(100dvh_-_48px))] sm:rounded-[32px] sm:border-8 sm:border-neutral-900">
        {children}
      </div>
    </div>
  )
}
