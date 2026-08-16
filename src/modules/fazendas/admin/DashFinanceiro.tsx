import { useState } from 'react'
import { BarChart } from '@/components/ui/BarChart'
import { Card } from '@/components/ui/Card'
import { ChartCard } from '@/components/ui/ChartCard'
import { FormField } from '@/components/ui/FormField'
import { FormSelect } from '@/components/ui/FormSelect'
import { KpiStatCard } from '@/components/ui/KpiStatCard'
import { SectionTitle } from '@/components/ui/Heading'
import { TextInput } from '@/components/ui/TextInput'
import { DashboardScreen } from './DashboardScreen'
import { FINANCEIRO } from '../mocks/dashboards'

const options = (values: string[]) => values.map((value) => ({ value, label: value }))

/** Dashboard consolidado conforme o painel financeiro e operacional observado no AGRO365. */
export function DashFinanceiro() {
  const [periodo, setPeriodo] = useState('Anual')
  const [visao, setVisao] = useState('Sintético')
  const [produto, setProduto] = useState('Todos os produtos')

  return (
    <DashboardScreen title="Financeiro e operacional">
      <Card className="mb-5">
        <SectionTitle className="mb-3">Filtros de análise</SectionTitle>
        <div className="grid grid-cols-2 gap-3">
          <FormField label="Período" htmlFor="dash-periodo">
            <FormSelect
              id="dash-periodo"
              value={periodo}
              onChange={(event) => setPeriodo(event.target.value)}
              options={options(['Anual', 'Mensal', 'Personalizado'])}
            />
          </FormField>
          <FormField label="Visão" htmlFor="dash-visao">
            <FormSelect
              id="dash-visao"
              value={visao}
              onChange={(event) => setVisao(event.target.value)}
              options={options(['Sintético', 'Analítico'])}
            />
          </FormField>
          <FormField label="Data inicial" htmlFor="dash-inicial">
            <TextInput id="dash-inicial" type="date" defaultValue="2026-01-01" />
          </FormField>
          <FormField label="Data final" htmlFor="dash-final">
            <TextInput id="dash-final" type="date" defaultValue="2026-12-31" />
          </FormField>
          <FormField label="Produto" htmlFor="dash-produto" className="col-span-2">
            <FormSelect
              id="dash-produto"
              value={produto}
              onChange={(event) => setProduto(event.target.value)}
              options={options(['Todos os produtos', 'Bovinos', 'Soja', 'Milho'])}
            />
          </FormField>
        </div>
      </Card>

      <SectionTitle className="mb-2">Posição financeira</SectionTitle>
      <div className="grid grid-cols-2 gap-3">
        <KpiStatCard label="A receber" value={FINANCEIRO.kpis.aReceber} tone="positive" />
        <KpiStatCard label="A pagar" value={FINANCEIRO.kpis.aPagar} />
        <KpiStatCard label="Saldo" value="R$ 880 mil" tone="positive" />
        <KpiStatCard label="Saldo realizado" value="R$ 642 mil" tone="positive" />
        <KpiStatCard label="Saldo previsto" value="R$ 238 mil" />
        <KpiStatCard label="Saldo atrasado" value={FINANCEIRO.kpis.atrasados} tone="negative" />
      </div>

      <SectionTitle className="mb-2 mt-6">Custos</SectionTitle>
      <div className="grid grid-cols-2 gap-3">
        <KpiStatCard label="Custo de produção" value="R$ 1,10 mi" />
        <KpiStatCard label="COE" value="R$ 824 mil" caption="Custo operacional efetivo" />
        <KpiStatCard label="COT" value="R$ 968 mil" caption="Custo operacional total" />
        <KpiStatCard label="Custeio" value="R$ 720 mil" />
        <KpiStatCard label="Custeio médio" value="R$ 31,20/cx" />
        <KpiStatCard label="Investimentos" value={FINANCEIRO.kpis.investimentos} />
      </div>

      <div className="mt-4">
        <ChartCard title="Composição do custo operacional" subtitle="Valores em milhares (R$)">
          <BarChart data={FINANCEIRO.centrosCusto} formatValue={(value) => `${value}k`} />
        </ChartCard>
      </div>

      <SectionTitle className="mb-2 mt-6">Produção</SectionTitle>
      <div className="grid grid-cols-3 gap-3">
        <KpiStatCard label="Vendida" value="842 t" />
        <KpiStatCard label="Estocada" value="318 t" />
        <KpiStatCard label="Total" value="1.160 t" tone="positive" />
      </div>

      <div className="mt-4">
        <ChartCard title="Resultados apurados" subtitle={`${periodo} · ${visao} · ${produto}`}>
          <BarChart
            data={[
              { label: 'Receitas', value: 2400 },
              { label: 'Despesas', value: 1100 },
              { label: 'Saldo', value: 1300 },
            ]}
            formatValue={(value) => `R$ ${value}k`}
          />
        </ChartCard>
      </div>
    </DashboardScreen>
  )
}
