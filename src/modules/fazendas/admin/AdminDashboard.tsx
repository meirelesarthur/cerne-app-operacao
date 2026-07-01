import { useParams } from 'react-router-dom'
import type { ComponentType } from 'react'
import { DashFinanceiro } from './DashFinanceiro'
import { DashPecuaria } from './DashPecuaria'
import { DashConfinamento } from './DashConfinamento'
import { DashAtivos } from './DashAtivos'
import { DashSuprimentos } from './DashSuprimentos'
import { DashUso } from './DashUso'
import { DashConsultas } from './DashConsultas'
import { EmSection } from '../screens/EmSection'

/** Resolve o dashboard administrativo pela rota /fazendas/dashboards/:dashId (spec §4). */
const DASHBOARDS: Record<string, ComponentType> = {
  financeiro: DashFinanceiro,
  pecuaria: DashPecuaria,
  confinamento: DashConfinamento,
  ativos: DashAtivos,
  suprimentos: DashSuprimentos,
  uso: DashUso,
  consultas: DashConsultas,
}

export function AdminDashboard() {
  const { dashId } = useParams()
  const Screen = dashId ? DASHBOARDS[dashId] : undefined
  if (!Screen) return <EmSection title="Dashboard" />
  return <Screen />
}
