import { Wallet, Package, Beef, HeartPulse, Baby } from 'lucide-react'
import { DashboardCard } from '@/components/ui/DashboardCard'
import { SectionTitle } from '@/components/ui/Heading'
import { ActivityListItem } from '../components/ActivityListItem'
import { DashboardScreen } from './DashboardScreen'
import { PECUARIA } from '../mocks/dashboards'
import { ATIVIDADES } from '../mocks/atividades'

const ICONS = [Wallet, Package, Beef]

/**
 * Dashboard Pecuária de Corte (spec §4.1).
 * Bloco Financeiro ativo; bloco Produtivo/Reprodutivo DESATIVADO (LACUNA no legado, §7.2).
 */
export function DashPecuaria() {
  return (
    <DashboardScreen title="Pecuária de Corte">
      <SectionTitle className="mb-2">Financeiro</SectionTitle>
      <div className="grid grid-cols-2 gap-3">
        {PECUARIA.financeiro.map((c, i) => (
          <DashboardCard
            key={c.label}
            icon={ICONS[i] ?? Beef}
            label={c.label}
            value={c.value}
            delta={c.delta}
            spark={c.spark}
          />
        ))}
      </div>

      <SectionTitle className="mb-2 mt-6">Produtivo / Reprodutivo</SectionTitle>
      <div className="grid grid-cols-2 gap-3">
        <DashboardCard icon={HeartPulse} label="Taxa de prenhez" value="—" disabled />
        <DashboardCard icon={Baby} label="Desmame" value="—" disabled />
      </div>
      <p className="mt-2 text-xs text-fg-subtle">
        Indicadores produtivos/reprodutivos em definição no legado — não exibidos para evitar dado incorreto.
      </p>

      <SectionTitle className="mb-2 mt-6">Atividades recentes do rebanho</SectionTitle>
      <div className="rounded-2xl border border-border-default bg-surface px-3">
        {ATIVIDADES.filter((a) => ['pesagem', 'evento', 'venda'].includes(a.kind))
          .slice(0, 4)
          .map((a) => (
            <ActivityListItem key={a.id} activity={a} />
          ))}
      </div>
    </DashboardScreen>
  )
}
