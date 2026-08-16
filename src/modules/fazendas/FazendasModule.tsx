import { Routes, Route, Navigate } from 'react-router-dom'
import { t } from '@/design/tokens'
import { SyncBanner } from './components/SyncBanner'
import { FazendasHome } from './screens/FazendasHome'
import { AtividadesScreen } from './screens/AtividadesScreen'
import { FarmListScreen } from './screens/FarmListScreen'
import { SyncQueueScreen } from './screens/SyncQueueScreen'
import { AdminDashboard } from './admin/AdminDashboard'
import { DashFinanceiro } from './admin/DashFinanceiro'
import { CampoFlow } from './operacional/CampoFlow'
import { ResponsibilityWorkspace } from './screens/ResponsibilityWorkspace'
import { MappedFeatureScreen } from './screens/MappedFeatureScreen'
import { useShellStore } from '@/shell/state/shellStore'

/**
 * Módulo Fazendas (ex-"Cerne") — módulo completo do superapp.
 * A troca de fazenda ativa vive na tela dedicada (tab "Fazendas" / FarmListScreen).
 * Administração e Operação têm rotas independentes e bloqueio cruzado por perfil.
 */
export function FazendasModule() {
  const role = useShellStore((s) => s.user.role)
  const isAdmin = role === 'admin'

  return (
    <div className="flex h-full flex-col bg-canvas">
      {/* O contexto offline continua compartilhado; as responsabilidades são separadas por rota. */}
      <SyncBanner />

      <div
        className="no-scrollbar flex-1 overflow-y-auto"
        style={{ paddingBottom: `calc(${t.layout.tabBarClearance} + env(safe-area-inset-bottom))` }}
      >
        <Routes>
          <Route index element={<FazendasHome />} />
          <Route path="atividades" element={<AtividadesScreen />} />
          <Route path="fazendas" element={<FarmListScreen />} />
          <Route path="financeiro" element={isAdmin ? <DashFinanceiro /> : <Navigate to="/fazendas/operacional" replace />} />
          <Route path="mais" element={<Navigate to={isAdmin ? '/fazendas/administracao' : '/fazendas/operacional'} replace />} />
          <Route path="mais/sync" element={!isAdmin ? <SyncQueueScreen /> : <Navigate to="/fazendas/administracao" replace />} />
          <Route path="administracao" element={isAdmin ? <ResponsibilityWorkspace role="administrativo" /> : <Navigate to="/fazendas/operacional" replace />} />
          <Route path="administracao/:featureId" element={isAdmin ? <MappedFeatureScreen role="administrativo" /> : <Navigate to="/fazendas/operacional" replace />} />
          <Route path="operacional" element={!isAdmin ? <ResponsibilityWorkspace role="operacional" /> : <Navigate to="/fazendas/administracao" replace />} />
          <Route path="operacional/:featureId" element={!isAdmin ? <MappedFeatureScreen role="operacional" /> : <Navigate to="/fazendas/administracao" replace />} />
          <Route path="dashboards/:dashId" element={isAdmin ? <AdminDashboard /> : <Navigate to="/fazendas/operacional" replace />} />
          <Route path="campo/:flowId" element={!isAdmin ? <CampoFlow /> : <Navigate to="/fazendas/administracao" replace />} />
          <Route path="*" element={<Navigate to="/fazendas" replace />} />
        </Routes>
      </div>
    </div>
  )
}
