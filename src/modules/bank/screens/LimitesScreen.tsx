import { Info } from 'lucide-react'
import { Heading, SectionTitle, Card, ProgressBar, Banner } from '@/components/ui'
import { useShellStore } from '@/shell/state/shellStore'
import { FAIXAS_LIMITE } from '@/modules/bank/mocks/banking'

/** Bank › Limites — faixas de limite (crédito, Pix, saque) com ocupação por ProgressBar. */
export function LimitesScreen() {
  const balanceHidden = useShellStore((s) => s.balanceHidden)

  return (
    <div className="flex flex-col gap-5 p-4">
      <div>
        <Heading level={3}>Limites</Heading>
        <p className="mt-0.5 text-sm text-fg-muted">Acompanhe o uso de cada faixa de limite da sua conta.</p>
      </div>

      <div>
        <SectionTitle className="mb-2">Faixas ativas</SectionTitle>
        <div className="flex flex-col gap-3">
          {FAIXAS_LIMITE.map((f) => (
            <Card key={f.id}>
              <div className="flex items-baseline justify-between gap-3">
                <span className="text-sm font-semibold text-fg">{f.label}</span>
                <span className="shrink-0 text-xs font-medium tabular-nums text-fg-muted">
                  {balanceHidden ? '••••' : f.usado} / {balanceHidden ? '••••' : f.total}
                </span>
              </div>
              <ProgressBar value={f.usadoPct} className="mt-2" colorByOccupancy />
              <p className="mt-1.5 text-xs text-fg-subtle">{f.usadoPct}% utilizado neste ciclo</p>
            </Card>
          ))}
        </div>
      </div>

      <Banner tone="info" icon={<Info size={14} aria-hidden="true" />}>
        Ajustes de limite passam por análise de crédito e são solicitados na tela de Cartões.
      </Banner>
    </div>
  )
}
