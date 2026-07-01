import type { ReactNode } from 'react'

/**
 * Frame de telefone centralizado — o protótipo é mobile-first (spec §1.4/§7.3).
 * Em telas largas mostra o app dentro de um "device"; em mobile ocupa a tela toda.
 */
export function PhoneFrame({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-full justify-center bg-neutral-200/60 sm:py-6">
      <div className="relative flex h-[100dvh] w-full max-w-phone flex-col overflow-hidden bg-canvas shadow-modal sm:h-[860px] sm:rounded-[32px] sm:border-8 sm:border-neutral-900">
        {children}
      </div>
    </div>
  )
}
