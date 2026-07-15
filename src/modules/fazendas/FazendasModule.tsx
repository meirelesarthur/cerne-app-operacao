import { Routes, Route, Navigate } from 'react-router-dom'
import { t } from '@/design/tokens'
import { SyncBanner } from './components/SyncBanner'
import { FazendasHome } from './screens/FazendasHome'
import { AtividadesScreen } from './screens/AtividadesScreen'
import { FarmListScreen } from './screens/FarmListScreen'
import { MaisScreen } from './screens/MaisScreen'
import { SyncQueueScreen } from './screens/SyncQueueScreen'
import { AdminDashboard } from './admin/AdminDashboard'
import { DashFinanceiro } from './admin/DashFinanceiro'
import { CampoFlow } from './operacional/CampoFlow'

/**
 * Módulo Fazendas (ex-"Cerne") — módulo completo do superapp.
 * A troca de fazenda ativa vive na tela dedicada (tab "Fazendas" / FarmListScreen).
 * As telas administrativas (dashboards) e operacionais (campo) chegam nas Fases 3 e 4;
 * por enquanto caem em EmSection.
 */
export function FazendasModule() {
  return (
    <div className="flex h-full flex-col bg-canvas">
      {/* O switch Gerencial ⇄ Campo vive no menu "Mais" (RevealMenu) — interface limpa */}
      <SyncBanner />

      <div
        className="no-scrollbar flex-1 overflow-y-auto"
        style={{ paddingBottom: `calc(${t.layout.tabBarClearance} + env(safe-area-inset-bottom))` }}
      >
        <Routes>
          <Route index element={<FazendasHome />} />
          <Route path="atividades" element={<AtividadesScreen />} />
          <Route path="fazendas" element={<FarmListScreen />} />
          <Route path="financeiro" element={<DashFinanceiro />} />
          <Route path="mais" element={<MaisScreen />} />
          <Route path="mais/sync" element={<SyncQueueScreen />} />
          <Route path="dashboards/:dashId" element={<AdminDashboard />} />
          <Route path="campo/:flowId" element={<CampoFlow />} />
          <Route path="*" element={<Navigate to="/fazendas" replace />} />
        </Routes>
      </div>
    </div>
  )
}
