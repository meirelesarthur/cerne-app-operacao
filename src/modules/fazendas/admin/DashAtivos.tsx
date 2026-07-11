import { useState, type ReactNode } from 'react'
import { KpiStatCard } from '@/components/ui/KpiStatCard'
import { ProgressBar } from '@/components/ui/ProgressBar'
import { Tag } from '@/components/ui/Tag'
import { Chip, type ChipTone } from '@/components/ui/Chip'
import { Card } from '@/components/ui/Card'
import { BottomSheet } from '@/components/ui/BottomSheet'
import { SectionTitle } from '@/components/ui/Heading'
import { Wrench, CheckCircle2 } from 'lucide-react'
import { DashboardScreen } from './DashboardScreen'
import { ATIVOS, ATIVOS_RESUMO, type Ativo, type AtivoEstado } from '../mocks/dashboards'

/** Rótulo + tom + ícone do estado do ativo — fonte única, reutilizado no detalhe. */
const ESTADO_META: Record<AtivoEstado, { label: string; tone: ChipTone; icon: ReactNode }> = {
  ativo: { label: 'Ativo', tone: 'brand', icon: <CheckCircle2 size={12} aria-hidden="true" /> },
  manutencao: { label: 'Em manutenção', tone: 'amber', icon: <Wrench size={12} aria-hidden="true" /> },
}

/** Dashboard de Ativos / Depreciação (spec §4.5). */
export function DashAtivos() {
  const [selected, setSelected] = useState<Ativo | null>(null)

  return (
    <DashboardScreen title="Ativos / Depreciação">
      <div className="grid grid-cols-3 gap-2">
        <KpiStatCard label="Total" value={ATIVOS_RESUMO.total} />
        <KpiStatCard label="Depreciação" value={ATIVOS_RESUMO.depreciacao} tone="negative" />
        <KpiStatCard label="Líquido" value={ATIVOS_RESUMO.liquido} tone="positive" />
      </div>

      <SectionTitle className="mb-2 mt-5">Equipamentos</SectionTitle>
      <div className="flex flex-col gap-2">
        {ATIVOS.map((a) => (
          <Card key={a.id} interactive padded={false} className="p-3" onClick={() => setSelected(a)}>
            <div className="flex items-start justify-between gap-2">
              <div className="min-w-0">
                <p className="truncate font-semibold text-fg">{a.nome}</p>
                <Tag className="mt-1">{a.categoria}</Tag>
              </div>
              <div className="shrink-0 text-right">
                <p className="text-sm font-semibold text-fg">{a.aquisicao}</p>
                <p className="flex items-center justify-end gap-1 text-xs text-fg-subtle">
                  <Wrench size={11} /> {a.proximaManutencao}
                </p>
              </div>
            </div>
            <div className="mt-2 flex items-center gap-2">
              <ProgressBar className="flex-1" value={a.depreciado} tone="amber" />
              <span className="text-xs font-medium text-fg-muted">{a.depreciado}%</span>
            </div>
          </Card>
        ))}
      </div>

      <BottomSheet open={!!selected} onClose={() => setSelected(null)} title="Detalhe do ativo">
        {selected && <AtivoSheetBody ativo={selected} />}
      </BottomSheet>
    </DashboardScreen>
  )
}

function AtivoSheetBody({ ativo }: { ativo: Ativo }) {
  const estado = ESTADO_META[ativo.estado]

  return (
    <div className="flex flex-col gap-4">
      {/* Identidade do ativo */}
      <div className="flex items-start justify-between gap-2">
        <div className="min-w-0">
          <Tag>{ativo.categoria}</Tag>
          <p className="mt-1 truncate text-lg font-semibold text-fg">{ativo.nome}</p>
        </div>
        <Chip tone={estado.tone} icon={estado.icon} className="shrink-0">
          {estado.label}
        </Chip>
      </div>

      {/* Ficha do ativo */}
      <div className="flex flex-col gap-3 rounded-2xl border border-border-default bg-surface-subtle p-4">
        <DetailRow label="Ano de aquisição" value={ativo.ano} />
        <DetailRow label="Valor de aquisição" value={ativo.aquisicao} />
        <DetailRow label="Valor residual" value={ativo.valorResidual} />
        <DetailRow
          label="Próxima manutenção"
          value={
            <span className="inline-flex items-center gap-1">
              <Wrench size={12} aria-hidden="true" /> {ativo.proximaManutencao}
            </span>
          }
        />
      </div>

      {/* Depreciação acumulada */}
      <div>
        <div className="mb-1 flex items-center justify-between">
          <span className="text-sm text-fg-muted">Depreciação acumulada</span>
          <span className="text-sm font-semibold text-fg">{ativo.depreciado}%</span>
        </div>
        <ProgressBar value={ativo.depreciado} tone="amber" />
      </div>

      {/* Padrão honesto do protótipo (como no DashConfinamento) */}
      <p className="text-sm text-fg-subtle">
        Ficha completa do ativo, histórico de manutenções e anexos ficam no sistema web GB CERNE.
      </p>
    </div>
  )
}

function DetailRow({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div className="flex items-baseline justify-between gap-3">
      <span className="shrink-0 text-sm text-fg-muted">{label}</span>
      <span className="min-w-0 truncate text-right text-sm font-semibold text-fg">{value}</span>
    </div>
  )
}
