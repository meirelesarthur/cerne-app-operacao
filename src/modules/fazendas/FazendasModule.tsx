import { Routes, Route, Navigate } from 'react-router-dom'
import { t } from '@/design/tokens'
import { ViewSwitch } from './components/ViewSwitch'
import { SyncBanner } from './components/SyncBanner'
import { FazendasHome } from './screens/FazendasHome'
import { AtividadesScreen } from './screens/AtividadesScreen'
import { FarmListScreen } from './screens/FarmListScreen'
import { MaisScreen } from './screens/MaisScreen'
import { EmSection } from './screens/EmSection'
import { AdminDashboard } from './admin/AdminDashboard'
import { DashFinanceiro } from './admin/DashFinanceiro'
import { CampoFlow } from './operacional/CampoFlow'

/**
 * Módulo Fazendas (ex-"Cerne") — módulo completo do superapp.
 * Header do módulo (FarmSwitcher + switch de visão) fica logo abaixo da barra de módulos do Shell.
 * As telas administrativas (dashboards) e operacionais (campo) chegam nas Fases 3 e 4;
 * por enquanto caem em EmSection.
 */
export function FazendasModule() {
  return (
    <div className="flex h-full flex-col" style={{ background: t.component.header.tabsBg }}>
      {/* Barra de visão do módulo — a pílula de fazenda vive no header do Shell (premium clean) */}
      <div className="px-4 pb-3 pt-1">
        <ViewSwitch />
      </div>

      <SyncBanner />

      <div className="no-scrollbar flex-1 overflow-y-auto rounded-t-3xl bg-surface">
        <Routes>
          <Route index element={<FazendasHome />} />
          <Route path="atividades" element={<AtividadesScreen />} />
          <Route path="fazendas" element={<FarmListScreen />} />
          <Route path="financeiro" element={<DashFinanceiro />} />
          <Route path="mais" element={<MaisScreen />} />
          <Route path="mais/sync" element={<EmSection title="Fila de sincronização" />} />
          <Route path="dashboards/:dashId" element={<AdminDashboard />} />
          <Route path="campo/:flowId" element={<CampoFlow />} />
          <Route path="*" element={<Navigate to="/fazendas" replace />} />
        </Routes>
      </div>
    </div>
  )
}
