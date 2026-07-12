import { Routes, Route, Navigate } from 'react-router-dom'
import { Construction } from 'lucide-react'
import { EmptyState } from '@/components/ui'
import { MarketplaceHome } from './screens/MarketplaceHome'
import { ProdutoDetalhe } from './screens/ProdutoDetalhe'
import { MarketplaceCategorias } from './screens/MarketplaceCategorias'
import { MarketplacePedidos } from './screens/MarketplacePedidos'
import { MarketplaceFavoritos } from './screens/MarketplaceFavoritos'

/**
 * Módulo Marketplace (New-UI): home com busca, categorias e ofertas de insumos.
 * Rotas relativas a /marketplace.
 */
export function MarketplaceModule() {
  return (
    <Routes>
      <Route index element={<MarketplaceHome />} />
      <Route path="produto/:id" element={<ProdutoDetalhe />} />
      <Route path="categorias" element={<MarketplaceCategorias />} />
      <Route path="pedidos" element={<MarketplacePedidos />} />
      <Route path="favoritos" element={<MarketplaceFavoritos />} />
      <Route
        path="ajuda"
        element={
          <EmptyState
            icon={Construction}
            title="Marketplace · Ajuda"
            description="Conteúdo em desenvolvimento. Esta área será detalhada em uma próxima fase."
            className="h-full justify-center"
          />
        }
      />
      <Route path="*" element={<Navigate to="/marketplace" replace />} />
    </Routes>
  )
}
