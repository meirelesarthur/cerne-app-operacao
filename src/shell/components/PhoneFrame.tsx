import type { ReactNode } from 'react'

/**
 * Frame de telefone centralizado — o protótipo é mobile-first (spec §1.4/§7.3).
 * Em mobile ocupa a tela toda (altura fixa no viewport, rolagem interna).
 * Em telas largas mostra o app dentro de um "device": a altura é mínima (não fixa),
 * então a moldura cresce com o conteúdo e quem rola é a página no navegador — nada é cortado.
 */
export function PhoneFrame({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-full justify-center bg-neutral-200/60 sm:py-6">
      <div className="relative flex h-[100dvh] w-full max-w-phone flex-col overflow-hidden bg-canvas shadow-modal sm:h-auto sm:min-h-[860px] sm:rounded-[32px] sm:border-8 sm:border-neutral-900">
        {children}
      </div>
    </div>
  )
}
