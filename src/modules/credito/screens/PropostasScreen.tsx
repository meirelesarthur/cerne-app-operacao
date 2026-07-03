import { Heading, KpiStatCard, Card, Chip } from '@/components/ui'
import type { ChipTone } from '@/components/ui'
import { PROPOSTAS, type PropostaStatus } from '../mocks/credito'

const STATUS_LABEL: Record<PropostaStatus, string> = {
  analise: 'Em análise',
  aprovada: 'Aprovada',
  contratada: 'Contratada',
}

const STATUS_TONE: Record<PropostaStatus, ChipTone> = {
  analise: 'amber',
  aprovada: 'brand',
  contratada: 'blue',
}

/** Total solicitado somado das propostas — pré-computado (sem matemática financeira em runtime). */
const TOTAL_SOLICITADO = 'R$ 526.500,00'
/** Soma das propostas com status aprovada/contratada. */
const TOTAL_APROVADO = 'R$ 276.500,00'

/**
 * Tela "Minhas propostas" do módulo Crédito: KPIs de acompanhamento e a
 * listagem completa das propostas em andamento ou concluídas.
 */
export function PropostasScreen() {
  return (
    <div className="flex flex-col gap-6 p-4">
      <Heading level={2}>Minhas propostas</Heading>

      <div className="grid grid-cols-2 gap-3">
        <KpiStatCard label="Total solicitado" value={TOTAL_SOLICITADO} />
        <KpiStatCard label="Aprovado" value={TOTAL_APROVADO} tone="positive" />
      </div>

      <Card padded={false} className="px-4">
        {PROPOSTAS.map((proposta) => (
          <div key={proposta.id} className="flex items-center gap-3 border-b border-border-default py-3 last:border-0">
            <div className="min-w-0 flex-1">
              <p className="truncate text-sm font-medium text-fg">{proposta.linha}</p>
              <p className="mt-0.5 text-xs text-fg-muted">{proposta.data}</p>
            </div>
            <div className="flex shrink-0 flex-col items-end gap-1">
              <p className="text-sm font-semibold tabular-nums text-fg">{proposta.valor}</p>
              <Chip tone={STATUS_TONE[proposta.status]}>{STATUS_LABEL[proposta.status]}</Chip>
            </div>
          </div>
        ))}
      </Card>
    </div>
  )
}
