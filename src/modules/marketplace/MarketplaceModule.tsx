import { Routes, Route, Navigate } from 'react-router-dom'
import { Construction } from 'lucide-react'
import { EmptyState } from '@/components/ui'
import { MarketplaceHome } from './screens/MarketplaceHome'

/**
 * Módulo Marketplace (New-UI): home com busca, categorias e ofertas de insumos.
 * Rotas relativas a /marketplace.
 */
export function MarketplaceModule() {
  return (
    <Routes>
      <Route index element={<MarketplaceHome />} />
      <Route
        path="categorias"
        element={
          <EmptyState
            icon={Construction}
            title="Marketplace · Categorias"
            description="Conteúdo em desenvolvimento. Esta área será detalhada em uma próxima fase."
            className="h-full justify-center"
          />
        }
      />
      <Route
        path="pedidos"
        element={
          <EmptyState
            icon={Construction}
            title="Marketplace · Pedidos"
            description="Conteúdo em desenvolvimento. Esta área será detalhada em uma próxima fase."
            className="h-full justify-center"
          />
        }
      />
      <Route
        path="mais"
        element={
          <EmptyState
            icon={Construction}
            title="Marketplace · Mais"
            description="Conteúdo em desenvolvimento. Esta área será detalhada em uma próxima fase."
            className="h-full justify-center"
          />
        }
      />
      <Route path="*" element={<Navigate to="/marketplace" replace />} />
    </Routes>
  )
}
