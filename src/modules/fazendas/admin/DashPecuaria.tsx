import { useState } from 'react'
import { BarChart } from '@/components/ui/BarChart'
import { Card } from '@/components/ui/Card'
import { ChartCard } from '@/components/ui/ChartCard'
import { FormField } from '@/components/ui/FormField'
import { FormSelect } from '@/components/ui/FormSelect'
import { KpiStatCard } from '@/components/ui/KpiStatCard'
import { SectionTitle } from '@/components/ui/Heading'
import { DashboardScreen } from './DashboardScreen'

const categories = [
  { label: 'Bezerros', value: 186 },
  { label: 'Novilhas', value: 142 },
  { label: 'Vacas', value: 318 },
  { label: 'Bois', value: 276 },
]

/** Dashboard pecuário com os indicadores observados no mapeamento funcional. */
export function DashPecuaria() {
  const [filtro, setFiltro] = useState('Todos os lotes')

  return (
    <DashboardScreen title="Dashboard pecuário">
      <Card className="mb-5">
        <FormField label="Filtros de análise" htmlFor="pecuaria-filtro">
          <FormSelect
            id="pecuaria-filtro"
            value={filtro}
            onChange={(event) => setFiltro(event.target.value)}
            options={['Todos os lotes', 'Lote 42', 'Lote 19', 'Lote 07'].map((value) => ({ value, label: value }))}
          />
        </FormField>
      </Card>

      <SectionTitle className="mb-2">Estoque atual</SectionTitle>
      <div className="grid grid-cols-2 gap-3">
        <KpiStatCard label="Animais nos lotes" value="922" tone="positive" />
        <KpiStatCard label="Categorias" value="4" caption={filtro} />
      </div>
      <div className="mt-4">
        <ChartCard title="Animais por categoria" subtitle="Cabeças no estoque atual">
          <BarChart data={categories} formatValue={(value) => `${value}`} />
        </ChartCard>
      </div>

      <SectionTitle className="mb-2 mt-6">Desempenho no intervalo</SectionTitle>
      <div className="grid grid-cols-2 gap-3">
        <KpiStatCard label="Dias" value="90" />
        <KpiStatCard label="Ganho total" value="18.440 kg" tone="positive" />
        <KpiStatCard label="Média animal" value="20,0 kg" />
        <KpiStatCard label="GMD global" value="0,74 kg/dia" tone="positive" />
      </div>

      <SectionTitle className="mb-2 mt-6">Última pesagem</SectionTitle>
      <div className="grid grid-cols-2 gap-3">
        <KpiStatCard label="Peso médio" value="472 kg" />
        <KpiStatCard label="Animais pesados" value="128" />
        <KpiStatCard label="GMD do lote" value="0,81 kg/dia" tone="positive" />
        <KpiStatCard label="Data" value="15/08" caption="Lote 42" />
      </div>
    </DashboardScreen>
  )
}
