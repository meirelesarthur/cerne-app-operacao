import { KpiStatCard } from '@/components/ui/KpiStatCard'
import { ChartCard } from '@/components/ui/ChartCard'
import { BarChart } from '@/components/ui/BarChart'
import { DashboardScreen } from './DashboardScreen'
import { FINANCEIRO } from '../mocks/dashboards'

/** Dashboard Financeiro (spec §4.3): posição por centro de custo, atrasos e investimentos. */
export function DashFinanceiro() {
  const { kpis, centrosCusto } = FINANCEIRO
  return (
    <DashboardScreen title="Financeiro">
      <div className="grid grid-cols-2 gap-3">
        <KpiStatCard label="A Receber" value={kpis.aReceber} tone="positive" />
        <KpiStatCard label="A Pagar" value={kpis.aPagar} />
        <KpiStatCard label="Atrasados" value={kpis.atrasados} tone="negative" caption="Vencidos > 0" />
        <KpiStatCard label="Investimentos" value={kpis.investimentos} />
      </div>

      <div className="mt-4">
        <ChartCard title="Despesas por centro de custo" subtitle="Valores em milhares (R$)">
          <BarChart data={centrosCusto} formatValue={(v) => `${v}k`} />
        </ChartCard>
      </div>
    </DashboardScreen>
  )
}
