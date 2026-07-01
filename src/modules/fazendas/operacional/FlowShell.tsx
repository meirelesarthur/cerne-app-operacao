import type { ReactNode } from 'react'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { ContextBadge } from '../components/ContextBadge'
import { Button } from '@/components/ui/Button'
import { Chip } from '@/components/ui/Chip'
import { useShellStore } from '@/shell/state/shellStore'

export interface FlowShellProps {
  title: string
  children: ReactNode
  /** rótulo do botão primário; ocultado se ausente. */
  primaryLabel?: string
  onPrimary?: () => void
  primaryDisabled?: boolean
  onBack?: () => void
}

/**
 * Esqueleto comum dos fluxos operacionais (spec §5): header + badge de contexto (fazenda)
 * + conteúdo + rodapé fixo com botão primário. Mostra chip de fila offline quando sem conexão.
 */
export function FlowShell({ title, children, primaryLabel, onPrimary, primaryDisabled, onBack }: FlowShellProps) {
  const isOnline = useShellStore((s) => s.isOnline)

  return (
    <div className="flex h-full flex-col bg-canvas">
      <SubPageHeader title={title} onBack={onBack} />
      <ContextBadge />
      <div className="no-scrollbar flex-1 overflow-y-auto p-4">{children}</div>

      {primaryLabel && (
        <div className="flex flex-col gap-2 border-t border-border-default bg-surface p-4 pb-[calc(1rem+env(safe-area-inset-bottom))]">
          {!isOnline && (
            <Chip tone="amber" className="self-start">
              Sem conexão — será enfileirado para sincronização
            </Chip>
          )}
          <Button fullWidth size="lg" onClick={onPrimary} disabled={primaryDisabled}>
            {primaryLabel}
          </Button>
        </div>
      )}
    </div>
  )
}
