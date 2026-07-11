import { useState } from 'react'
import { Heading, Card, Chip, ProgressBar, BottomSheet } from '@/components/ui'
import { CONTRATOS, type Contrato } from '../mocks/credito'

/**
 * Tela "Contratos" do módulo Crédito: contratos ativos do produtor com progresso
 * de parcelas pagas. Cada item abre um resumo (próxima parcela, vencimento, saldo).
 */
export function ContratosScreen() {
  const [selecionado, setSelecionado] = useState<Contrato | null>(null)

  return (
    <div className="flex flex-col gap-6 p-4">
      <Heading level={2}>Contratos</Heading>

      <div className="flex flex-col gap-3">
        {CONTRATOS.map((contrato) => (
          <Card key={contrato.id} interactive onClick={() => setSelecionado(contrato)}>
            <div className="flex items-center justify-between gap-2">
              <p className="truncate text-sm font-semibold text-fg">{contrato.linha}</p>
              <Chip tone="brand">Em dia</Chip>
            </div>
            <p className="mt-1 text-lg font-bold tabular-nums text-fg">{contrato.valor}</p>
            <div className="mt-3">
              <ProgressBar value={contrato.parcelasPagas} max={contrato.parcelasTotal} />
              <p className="mt-1.5 text-xs text-fg-muted">
                {contrato.parcelasPagas} de {contrato.parcelasTotal} parcelas pagas
              </p>
            </div>
          </Card>
        ))}
      </div>

      <BottomSheet open={!!selecionado} onClose={() => setSelecionado(null)} title={selecionado?.linha}>
        {selecionado && (
          <div className="flex flex-col gap-3">
            <div className="flex items-center justify-between">
              <span className="text-fg-muted">Próxima parcela</span>
              <span className="font-semibold text-fg">{selecionado.proximaParcela}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-fg-muted">Vencimento</span>
              <span className="font-semibold text-fg">{selecionado.vencimento}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-fg-muted">Saldo devedor</span>
              <span className="font-semibold text-fg">{selecionado.saldoDevedor}</span>
            </div>
          </div>
        )}
      </BottomSheet>
    </div>
  )
}
