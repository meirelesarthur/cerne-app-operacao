import { KpiStatCard } from '@/components/ui/KpiStatCard'
import { ProgressBar } from '@/components/ui/ProgressBar'
import { Tag } from '@/components/ui/Tag'
import { SectionTitle } from '@/components/ui/Heading'
import { Wrench } from 'lucide-react'
import { DashboardScreen } from './DashboardScreen'
import { ATIVOS, ATIVOS_RESUMO } from '../mocks/dashboards'

/** Dashboard de Ativos / Depreciação (spec §4.5). */
export function DashAtivos() {
  return (
    <DashboardScreen title="Ativos / Depreciação">
      <div className="grid grid-cols-3 gap-2">
        <KpiStatCard label="Total" value={ATIVOS_RESUMO.total} />
        <KpiStatCard label="Depreciação" value={ATIVOS_RESUMO.depreciacao} tone="negative" />
        <KpiStatCard label="Líquido" value={ATIVOS_RESUMO.liquido} tone="positive" />
      </div>

      <SectionTitle className="mb-2 mt-5">Equipamentos</SectionTitle>
      <ul className="flex flex-col gap-2">
        {ATIVOS.map((a) => (
          <li key={a.id} className="rounded-2xl border border-border-default bg-surface p-3">
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
          </li>
        ))}
      </ul>
    </DashboardScreen>
  )
}
