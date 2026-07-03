import { Routes, Route, Navigate } from 'react-router-dom'
import { HubHome } from './screens/HubHome'
import { AppsScreen } from './screens/AppsScreen'
import { CarteiraScreen } from './screens/CarteiraScreen'

/**
 * Módulo Início (New-UI) — hub agregador do superapp: Banking central,
 * catálogo de mini-apps e carteira condensada. Rotas relativas a /inicio.
 */
export function HubModule() {
  return (
    <Routes>
      <Route index element={<HubHome />} />
      <Route path="apps" element={<AppsScreen />} />
      <Route path="carteira" element={<CarteiraScreen />} />
      <Route path="*" element={<Navigate to="/inicio" replace />} />
    </Routes>
  )
}
