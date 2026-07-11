import type { ReactNode } from 'react'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { Button } from '@/components/ui'

export interface BankFlowShellProps {
  title: string
  onBack: () => void
  children: ReactNode
  /** Rótulo do botão primário; ocultado se ausente. */
  primaryLabel?: string
  onPrimary?: () => void
  primaryDisabled?: boolean
  /** Ação opcional no canto do header (ex.: passo atual). */
  headerAction?: ReactNode
}

/**
 * Esqueleto comum dos fluxos de pagamento do GB Bank: header com voltar +
 * conteúdo + rodapé com botão primário. Equivalente ao FlowShell de Fazendas,
 * porém sem o contexto de fazenda/fila offline (composição local, Lei 1).
 */
export function BankFlowShell({
  title,
  onBack,
  children,
  primaryLabel,
  onPrimary,
  primaryDisabled,
  headerAction,
}: BankFlowShellProps) {
  return (
    <div className="flex min-h-full flex-col bg-canvas">
      <SubPageHeader title={title} onBack={onBack} action={headerAction} />
      <div className="flex-1 p-4">{children}</div>
      {primaryLabel && (
        <div className="border-t border-border-default bg-surface p-4">
          <Button fullWidth size="lg" onClick={onPrimary} disabled={primaryDisabled}>
            {primaryLabel}
          </Button>
        </div>
      )}
    </div>
  )
}
