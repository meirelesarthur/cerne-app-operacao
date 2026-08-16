import { useState } from 'react'
import { KpiStatCard } from '@/components/ui/KpiStatCard'
import { ProgressBar } from '@/components/ui/ProgressBar'
import { BottomSheet } from '@/components/ui/BottomSheet'
import { Chip } from '@/components/ui/Chip'
import { SectionTitle } from '@/components/ui/Heading'
import { Pressable } from '@/components/ui/Pressable'
import { DashboardScreen } from './DashboardScreen'
import { CURRAIS, type Curral } from '../mocks/dashboards'

/** Dashboard Lotação de Currais / Confinamento (spec §4.2). */
export function DashConfinamento() {
  const [selected, setSelected] = useState<Curral | null>(null)

  const totalCap = CURRAIS.reduce((s, c) => s + c.max, 0)
  const totalAtual = CURRAIS.reduce((s, c) => s + c.atual, 0)
  const ocupacao = Math.round((totalAtual / totalCap) * 100)
  const disponiveis = CURRAIS.filter((c) => c.atual < c.max).length

  return (
    <DashboardScreen title="Lotação de Currais">
      <div className="grid grid-cols-3 gap-2">
        <KpiStatCard label="Ocupação" value={`${ocupacao}%`} tone={ocupacao >= 80 ? 'warning' : 'positive'} />
        <KpiStatCard label="Disponíveis" value={String(disponiveis)} />
        <KpiStatCard label="Cabeças" value={String(totalAtual)} />
      </div>

      <SectionTitle className="mb-2 mt-5">Mapa de currais</SectionTitle>
      <div className="grid grid-cols-2 gap-3">
        {CURRAIS.map((c) => {
          const pct = Math.round((c.atual / c.max) * 100)
          return (
            <Pressable
              key={c.id}
              onClick={() => setSelected(c)}
              className="rounded-2xl border border-border-default bg-surface p-3 text-left shadow-card active:scale-[0.99]"
            >
              <div className="flex items-center justify-between">
                <p className="font-semibold text-fg">{c.nome}</p>
                <Chip tone={pct >= 100 ? 'red' : pct >= 80 ? 'amber' : 'brand'}>{pct}%</Chip>
              </div>
              <p className="text-xs text-fg-muted">{c.setor}</p>
              <p className="mt-2 text-sm text-fg">
                {c.atual}
                <span className="text-fg-subtle">/{c.max}</span>
              </p>
              <ProgressBar className="mt-1" value={c.atual} max={c.max} colorByOccupancy />
            </Pressable>
          )
        })}
      </div>

      <BottomSheet open={!!selected} onClose={() => setSelected(null)} title={selected?.nome}>
        {selected && (
          <div className="flex flex-col gap-3">
            <div className="flex items-center justify-between">
              <span className="text-fg-muted">Setor</span>
              <span className="font-semibold text-fg">{selected.setor}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-fg-muted">Ocupação</span>
              <span className="font-semibold text-fg">
                {selected.atual}/{selected.max} cabeças
              </span>
            </div>
            <ProgressBar value={selected.atual} max={selected.max} colorByOccupancy showLabel />
            <p className="mt-2 text-sm text-fg-subtle">
              Histórico de ocupação e movimentações do curral aparecem aqui na versão completa.
            </p>
          </div>
        )}
      </BottomSheet>
    </DashboardScreen>
  )
}
